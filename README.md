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

Can pass in the options for [load-image](https://github.com/blueimp/JavaScript-Load-Image#options)
* loadImage - { ... load image options ... }
* callback - function that gets the photo object as a parameter. Where the photo object is

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
  // See source for all the css vars
}
```


## TODO

* cropping


## License
MIT

