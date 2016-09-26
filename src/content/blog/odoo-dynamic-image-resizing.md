+++
author = "RIDING BYTES"
categories = ["Odoo", "Development"]
date = "2016-01-04T11:44:06+01:00"
description = ""
draft = false
summary = "Scale images on the fly"
title = "Odoo: Dynamic image resizing"
#img = "odoo-grid.png"
+++

# Odoo: Scale images on the fly

Odoo uses Python Imaging Library (PIL) to support image resizing on the fly.
This functionality ships with the `image.py` module, which is located in
`openerp.tools.image`.

## Problem

I implemented a custom model which defined a binary field called `image`:

{{< highlight python >}}
class MyModel(models.Model):
    _name = 'my.model'

    image = fields.Binary('Image', required=True)
    image_filename = fields.Char("Image Filename")
{{< /highlight >}}

I wanted to use this model within in a website view, but struggled with finding
a suitable image source URL for the image field. Unfortunately it was only
possible to access the `base64` encoded image data.

Thus, I ended up using the inline data option within the `src` attribute of the
image tag:

{{< highlight html >}}
<img t-attf-src="data:image/jpg;base64,{{ my.model.image }}" />
{{< /highlight >}}

This actually worked quite well, but using the raw `base64` data within the
HTML feels kind of awkward to me and it also uses the full image size, which
was not suitable for me.


## Solution

Odoo's `website` addon ships with a controller, which allows to access image
fields of any model through an URL. This controller is located in
`odoo/addons/website/controllers/main.py` and offers this route:

{{< highlight python >}}
@http.route([
    '/website/image',
    '/website/image/<model>/<id>/<field>',
    '/website/image/<model>/<id>/<field>/<int:max_width>x<int:max_height>'
    ], auth="public", website=True, multilang=False)
def website_image(self, model, id, field, max_width=None, max_height=None):
    """ Fetches the requested field and ensures it does not go above
    (max_width, max_height), resizing it if necessary.

    If the record is not found or does not have the requested field,
    returns a placeholder image via :meth:`~.placeholder`.

    Sets and checks conditional response parameters:
    * :mailheader:`ETag` is always set (and checked)
    * :mailheader:`Last-Modified is set iif the record has a concurrency
      field (``__last_update``)

    The requested field is assumed to be base64-encoded image data in
    all cases.
    """
{{< /highlight >}}

With this route, I could change my inline rendered image to use this URL and do
the resizing as well:

{{< highlight html >}}
<img t-attf-src="/website/image/my.model/{{ my.model.id }}/image/128x128" />
{{< /highlight >}}


## Going further

As I could use this nice URL to access the image of my custom model, I thought
about using an attribute on the model to provide the scaled image directly.
Therefore I changed the code of my model and added the fields `image_medium`
and `image_small`:

{{< highlight python >}}
class MyModel(models.Model):
    _name = 'my.model'

    image = fields.Binary('Image', required=True)
    image_filename = fields.Char("Image Filename")

    # Scaled Images
    image_medium = fields.Binary(string="Medium-sized image",
                                 store=False,
                                 compute="_get_image",
                                 help="Medium-sized image of this model. It is automatically " \
                                      "resized as a 128x128px image, with aspect ratio preserved. " \
                                      "Use this field in form views or some kanban views.")

    image_small = fields.Binary(string="Small-sized image",
                                store=False,
                                compute="_get_image",
                                help="Small sized image of this model. It is automatically " \
                                     "resized as a 64x64px image, with aspect ratio preserved. " \
                                     "Use this field in form views or some kanban views.")

{{< /highlight >}}

{{< img src="/media/blog/odoo-dynamic-image-resizing.png" class="image-left" >}}

I also wanted to prevent that the images get stored in the database, to avoid
unnecessary data growth. Therefore I used a computed field
(`compute="_get_image"`) and passed in the `store=False` option.

My first shot of the `_get_image` method looked like this:

{{< highlight python >}}
class MyModel(models.Model):
    _name = 'my.model'

    [...]

    @api.one
    @api.depends("image")
    def _get_image(self):
        """ calculate the images sizes and set the images to the corresponding
            fields
        """
        image = self.image

        data = tools.image_get_resized_images(image)
        self.image_medium = data["image_medium"]
        self.image_small = data["image_small"]
        return True

{{< /highlight >}}

I was unlucky again, since this code worked exactly once, and that was when the
`image` field was initially set.

The problem was, that after the `image` field was set, a `context` variable
with the name `bin_size` and the value `True` was set, which instructed the
image field to return only the image size instead of the full `base64` encoded
image. The complete `context` I inspected within this method looked like this:

{{< highlight python >}}
ipdb> self.env.context
{'lang': 'en_US', 'bin_size': True, 'tz': 'Europe/Berlin', 'uid': 1}
{{< /highlight >}}

I found the corresponding field definition for the binary field in `openerp.osv.fields`:

{{< highlight python >}}
class binary(_column):
    _type = 'binary'
    [...]
    def get(self, cr, obj, ids, name, user=None, context=None, values=None):
        [...]

        # If client is requesting only the size of the field, we return it instead
        # of the content. Presumably a separate request will be done to read the actual
        # content if it's needed at some point.
        # TODO: after 6.0 we should consider returning a dict with size and content instead of
        #       having an implicit convention for the value
        if val and context.get('bin_size_%s' % name, context.get('bin_size')):
            res[i] = tools.human_size(long(val))
        [...]
{{< /highlight >}}

After some research I figured out that it is possible to overwrite this
immutable `context` with the method `with_context` on the model itself.

http://odoo-new-api-guide-line.readthedocs.org/en/latest/environment.html#modifing-environment

So the final version of my `_get_image` method looked like this:

{{< highlight python >}}
class MyModel(models.Model):
    _name = 'my.model'

    [...]

    @api.one
    @api.depends("image")
    def _get_image(self):
        """ calculate the images sizes and set the images to the corresponding
            fields
        """
        image = self.image

        # check if the context contains the magic `bin_size` key
        if self.env.context.get("bin_size"):
            # refetch the image with a clean context
            image = self.env[self._name].with_context({}).browse(self.id).image

        data = tools.image_get_resized_images(image)
        self.image_medium = data["image_medium"]
        self.image_small = data["image_small"]
        return True

{{< /highlight >}}

Now it was possible to access the computed fields directly with the URL of the
`website` controller:

{{< highlight html >}}
<img t-attf-src="/website/image/my.model/{{ my.model.id }}/image_small" />
{{< /highlight >}}

Or simply by the URL itself:

http://localhost:8069/website/image/my.model/1/image_medium


## Conclusion

The size calculation of the images takes some time and this should be
considered with regard to the servers performance. So I guess it makes
more sense to actually store the image scales in the database to avoid
this workaround described above.

I also think that the workaround bypasses security, since it removes the `uid`
from the context as well. But I didn't investigate it any further.

The whole excursion was more or less driven by curiosity, since I only found
instructions in the internet on how to do this using the old Odoo V7 API.

The closest tutorial I found was this here:

http://www.odoo.yenthevg.com/saving-and-resizing-images-in-odoo-8

So I hope this is useful for someone:)

{{< divider >}}
