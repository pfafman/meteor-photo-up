
DEBUG = true

###
class PhotoUploadHandler

  defaults =
    #serverUploadMethod:     "submitPhoto"
    #serverUploadOptions:    {}
    uploadButtonLabel:      "Upload"
    takePhotoButtonLabel:   "Take Photo"
    #resizeMaxHeight:        300
    #resizeMaxWidth:         300
    allowCropping:          true
    editTitle:              false
    editCaption:            false

  options = {}

    
  constructor: (options) ->
    @setOptions(options)
    @_previewImage = new ReactiveVar()
    @_cropCords = new ReactiveVar()
  

  setOptions: (options = {}) ->
    @options = _.defaults(options, @options, @defaults)
      

  _iOS: ->
    window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)


  _maxPreviewImageWidth: ->
    if @_iOS()
      @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())
    else
      @options.resizeMaxWidth || (0.9 * $('.photo-uploader-control').width())


  _maxPreviewImageHeight: ->
    @options.resizeMaxHeight

  
  reset: ->
    # nothing
    @_reset()


  _reset: ->
    console.log("reset") if DEBUG
    @_previewImage.set(null)
    @_cropCords.set(null)
    @jcrop?.destroy()


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
            loadImage file, (img) ->
              tmpl.photo.set
                name: file.name.split('.')[0]
                filesize: file.size
                img: img
                src: img.toDataURL()
                size: img.toDataURL().length
                newImage: true
                orientation: data?.exif?.get?('Orientation') or 1
                
              if tmpl.allowCropping
                console.log("TODO: Jcrop") if DEBUG
                #doJcrop()

              #$('#photo-preview-dialog').modal
              #  show: true
            ,
              maxHeight: options.maxHeight or 300
              maxWidth: options.maxWidth or 300
              orientation: data?.exif?.get?('Orientation') or 1
              canvas: true

        else
          toast("Cannot read #{file.type} file #{file.name}", 3000, 'red')

    false




