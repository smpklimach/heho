+++
author = "Kloster Helfta"
categories = ["Odoo", "Development"]
date = "2016-03-06T23:44:26+01:00"
description = "Odoo Developer Mode Bookmarklet"
draft = false
summary = "Activate Odoo Developer with a Bookmarklet"
title = "Odoo: Developer mode"
#img = "../path/to/media/blog/image"
+++

# Odoo: Access Technical Features

In Odoo 9 you might miss the `Technical Features` checkbox in the *Access
Rights* of your user. These settings are now visible if you activate the
**Developer Mode** from the **About** menu.

I had to access this many times during development and found out, that I lose
too much time accessing the menu and clicking on the button. I had to change
this!

I created this small [Bookmarklet]({{< relref "#bookmarklet" >}}),
which toggles the developer mode by a single click...

{{< figure src="/media/blog/odoo-about.png" class="image-center" >}}



## Odoo Developer Bookmarklet {#bookmarklet}


Drag&Drop this Button to your Bookmarks Bar to toggle Odoo Developer Mode:

<a class="btn btn-success" href="javascript:(function(){
  var url=location.href.split(location.hash)[0];
  if(!url.endsWith('?debug')){
    location.href=url+'?debug'+location.hash;
  }else{
    if (confirm('Already in developer Mode. Do you want to Leave?')){
      url=url.split('?debug')[0];
      location.href=url+location.hash;
    }
  }})()">
  Toggle Odoo Dev-Mode
</a>

{{< figure src="/media/blog/odoo-dev-mode-toggle.png" class="image-left" >}}

{{< divider >}}
