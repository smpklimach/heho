Blog
====

This section describes how to create a new blog entry


Before you Start
----------------

Please make sure you are running `grunt` in the project folder. This will
auto-generate the website and serve a local web server on http://localhost:8000


Create a new Post
-----------------

New blog posts are created by the command line:

.. code-block:: bash

   cd <project-dir>/src

   hugo new blog/bika-partnership.md

.. note:: The `hugo` command knows that it has to go into the `contents` folder.


The new blog post will have a header with default values suitable for the
website. It is initially in the `draft` state, which will be not visible by
public users. The `categories` specify the "tags" of this article and generate
an automatic navigation widget on the page. The Image defined in `img` must be
located in `src/content/media`. This image will be used in the listing view and
should have the dimensions `1024x768`.

Example:

.. code-block:: ini

    +++
    author = "RIDING BYTES"
    categories = ["Web", "Development", "JS", "ExtJS", "Plone"]
    date = "2015-12-17T21:53:09+01:00"
    description = "This text is displayed below the title on the blog page"
    draft = true
    title = "bika partnership"
    img = "bika-partnership.jpg"
    summary = "This summary is displayed on the blog listing"
    +++

Description:

.. code-block:: ini

    draft = If `true`, then the article is invisible for website visitors

    img = An image located in scr/content/media, which will be displayed
          in the blog listing

    summary = Teaser text displayed in the blog listing

    description = Secondary headline on the blog page



.. note:: For a detailed description about the front matter, visit the
          documentation of Hugo http://gohugo.io/content/front-matter

Adding Content
..............

The content starts right after the last `+++` marker. The content must be
written in markdown (http://markdown.de).


Shortcodes
..........

You can add *Shortcodes* to your content to enable multimedia contents, e.g.
YouTube videos, images, twitter feeds etc. directly inline the text.

For general Shortcodes visit http://gohugo.io/extras/shortcodes.

Custom Shortcodes are located in `src/themes/ridingbytes/layouts/shortcodes`.

Example:

.. code-block:: rst

   - Embedded twitter feed:
                
     {{< tweet 676372319506444288>}}

   - Image:
   
     {{< img src="/media/blog/bika-partnership.png" class="image-left" >}}
