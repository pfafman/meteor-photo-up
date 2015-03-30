Photo Up
====================

Meteor package to upload (*into the Meteor client*), resize and crop an image.

*Warning: Only works with Meteor 1.0.4+*

Currently uses [Materialize](http://materializecss.com) for the UI.  You are responsible for  installing Materialize.  
Will remove in the future or make other frameworks an option.

## Install

```bash
meteor add pfafman:photo-up
```

## Usage

In a template add
```html
<template name="myTemplate">
	{{> photoUp photoUpOptions}}
</template>
```

then in the templates javascript/coffeescript file
```coffeescript
Template.myTemplate.helpers
    photoUpOptions: ->
        loadImage:
           # ... see loadImage site
        crop: true # If true do jCrop with setting below
        jCrop:
        	# ... see jcrop site
        callback: (error, photo) ->
           # Do what you want with the photo.  Save it?
```

### Options

Can pass in the options for [load-image](https://github.com/blueimp/JavaScript-Load-Image#options) and [Jcrop](http://deepliquid.com/content/Jcrop_Manual.html#Setting_Options)

* loadImage - { ... load image options [see site](https://github.com/blueimp/JavaScript-Load-Image#options) ... }


* crop - bool if true then do jCrop after upload.

* jCrop - { ... Jcrop options [see site](http://deepliquid.com/content/Jcrop_Manual.html#Setting_Options) ... }

* framework - Choose framework.  Only option currently is 'materialize' the default

* showInfo - bool show image information

* showClear - Show button to clear the image. 

* minDisplayWidth: minimum width for the display window
    
* minDisplayHeight: minimum height for the display window

* callback - function that gets the photo object as a parameter when ever it changes.

```
	photo:
	  name: file.name         # (without the type suffix)
      filesize: file.size
      img: img                # the img returned from load-image
      src: img.toDataURL()
      size: img.toDataURL().length
      newImage: true
      orientation: (from exif or 1)
```


## UI
You can change the UI by overwriting the CSS.

```
.photo-up  {
  // See source CSS for the source variables.
}
```


## TODO

* Make UI framework agnostic or implement other frameworks (bootstrap ...)
* Mess with jCrop for if you start messing with sizing the cropping can get all messed up.

## License
MIT

