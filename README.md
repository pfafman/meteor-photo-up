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
        rtn =
            loadImage:
                # ...
```

### Options

Can pass in the options for [loadImage](https://github.com/blueimp/JavaScript-Load-Image#options)
* loadImage - { ... load image options ... }



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

