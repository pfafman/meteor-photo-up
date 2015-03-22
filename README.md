Photo Up
====================

Meteor package to upload, resize and crop and image.

*Warning: Only works with Meteor 1.0.4+*

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
           # ...
        callback: (error, photo) ->
           # Do what you want with the photo.  Save it?
```

### Options

Can pass in the options for [load-image](https://github.com/blueimp/JavaScript-Load-Image#options) and [Jcrop](http://deepliquid.com/content/Jcrop_Manual.html#Setting_Options)

* loadImage - { ... load image options [see site](https://github.com/blueimp/JavaScript-Load-Image#options) ... }

* jCrop - { ... Jcrop options [see site](http://deepliquid.com/content/Jcrop_Manual.html#Setting_Options) ... }

* showInfo - bool show image information

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

This is also available in the *global* reactive-var `PhotoUp`.  This will have the last image set and will cause problems if you have multiple instances.  *Note: Trying to come up with a different approach.*


## UI
You can change the UI by overwriting the CSS.

```
.photo-up  {
  // See source CSS for the source variables.
}
```


## TODO

* Better approach for a reactive var that returns the photo.


## License
MIT

