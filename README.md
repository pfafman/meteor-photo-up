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
        # options ...
```

### Options

* maxHeight - the image will be resized not to exceed this height
* maxWidth - the image will be resized not to exceed this width


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

