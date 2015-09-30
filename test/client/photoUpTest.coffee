

DEBUG = true

Template.photoUpTest.onCreated ->
  # ...


Template.photoUpTest.onRendered ->
  # ...


Template.photoUpTest.onDestroyed ->
  # ...


Template.photoUpTest.helpers
  photoUpOptions: ->
    crop: true
    showInfo: true
    showClear: true

    loadImage:
      #canvas: true
      #crop: true
      cover: true
      maxWidth: 480
      maxHeight: 300
      #aspectRatio: 1.6

    callback: (error, photo) ->
      if error
        console.error("photoUp Error:", error)
      else
        console.log("photoUp photo:", photo)


Template.photoUpTest.events
  'click': (event, tmpl) ->
    # ...
