
DEBUG = true

###

  doJcrop: ->
    self = @
    $('#photoUploadPreview').Jcrop
      onSelect: (cords) =>
        @_cropCords.set(cords)
      onRelease: =>
        @_cropCords.set(null)
    , ->
      self.jcrop = @
    .parent().on "click", (event) ->
      event.preventDefault()
###

iOS: ->
  window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)


Template.photoUp.onCreated ->
  @photo = new ReactiveVar()
  @processing = new ReactiveVar(null)


Template.photoUp.onRendered ->
  console.log("turn off drag over") if DEBUG
  $(document).on "dragover", (e) ->
    console.log("document dragover") if DEBUG
    e.preventDefault()
    false

  $(document).on "drop", (e) ->
    console.log("document drop") if DEBUG
    e.preventDefault()
    false


Template.photoUp.onDestroyed ->
  $(document).off "dragover"
  $(document).off "drop"


Template.photoUp.helpers
  
  photo: ->
    Template.instance().photo.get()

  newDirections: ->
    @newDirections or "Drop image here"

  replaceDirections: ->
    @replaceDirections or "Drop new image to replace"

  noContent: ->
    if not @showInfo and not @showClear
      "no-content"

Template.photoUp.events
  
  'click .reset': (e, tmpl) ->
    Template.instance().photo.set(null)
    

  'dragover .dropbox': (e, tmpl) ->
    evt = e.originalEvent or e
    evt.dataTransfer.dropEffect = 'copy'


  'dragenter .dropbox': (e, tmpl) ->
    e.preventDefault()
    console.log("dragenter dropbox") if DEBUG
    false


  'dragleave .dropbox': (e, tmpl) ->
    e.preventDefault()
    console.log("dragleave dropbox") if DEBUG
    false


  #'ondrag .dropbox': (e, tmpl) ->
  #  e.preventDefault()
  #  console.log("drag dropbox") if DEBUG


  'drop .dropbox': (e, tmpl) ->
    tmpl.processing.set("Processing file ...")
    e.preventDefault()
    evt = e.originalEvent or e
    files = evt.target.files or evt.dataTransfer?.files
    console.log("dropped", evt, files) if DEBUG
    
    if files?
      for file in files
        console.log("Droppecd file", file.name, file.size, file.type) if DEBUG
        options = @
        if file.type.indexOf("image") is 0
          loadImage.parseMetaData file, (data) ->

            loadImage.options = _.defaults options.loadImage or {},
              canvas: true
              orientation: data?.exif?.get?('Orientation') or 1

            loadImage file, (img) ->
              photo =
                name: file.name.split('.')[0]
                filesize: file.size
                img: img
                src: img.toDataURL()
                size: img.toDataURL().length
                newImage: true
                orientation: data?.exif?.get?('Orientation') or 1
              
              tmpl.photo.set(photo)

              if tmpl.allowCropping
                console.log("TODO: Jcrop") if DEBUG
                #doJcrop()

              options.callback?(photo)

              #$('#photo-preview-dialog').modal
              #  show: true
            , loadImage.options

        else
          toast("Cannot read #{file.type} file #{file.name}", 3000, 'red')

    false




