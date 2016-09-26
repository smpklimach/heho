+++
author = "RIDING BYTES"
categories = ["Odoo", "Development"]
date = "2016-01-02T19:26:32+01:00"
description = ""
draft = false
title = "Odoo: Remember the filename of binary files"
summary = "Keep the filename and extension of binary files in Odoo"
#img = "odoo-white.svg"
+++

# Odoo: Remember the filename of binary files

## Problem

I wanted to use a binary field to store image data to a custom model.
Therefore I used a field of the type `Binary` in my model. Unfortunately only
the base64 encoded file was stored in the database but not the filename. This
resulted in an unknown binary file download with the name of the current model.

<!--more-->

## Solution

Luckily I found a solution for this problem. First, I added another field to my
model to store the filename. The name of this field can be arbitrary.
The next step was to tell the image widget to use this field to store the filename:
`<field widget="binary" height="64" name="image" filename="image_filename" />`.

Below is the full code listing to make it work:

### Python Code

{{< highlight python >}}
class MyModel(models.Model):
    _name = 'my.model'

    image = fields.Binary('Image', required=True)
    image_filename = fields.Char("Image Filename")
{{< /highlight >}}


### XML View

{{< highlight xml >}}
<record id="view_form_my_model" model="ir.ui.view">
  <field name="name">My Model Form</field>
  <field name="model">my.model</field>
  <field name="arch" type="xml">
    <form>
      <sheet>
        <group name="group_top">
          <group name="group_left">
            <field name="image_filename" invisible="0"/>
            <field widget="binary" height="64" name="image" filename="image_filename" />
          </group>
          <group name="group_right">
          </group>
        </group>
      </sheet>
    </form>
  </field>
</record>
{{< /highlight >}}


## Result

The download works now like a charm and it is even possible to modify the
filename directly.

{{< img src="/media/blog/odoo-filename-handling.png" class="image-left" >}}

{{< divider >}}
