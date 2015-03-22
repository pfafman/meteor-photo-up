
DEBUG = true


iOS: ->
  window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)

# Global  arrrggg
@PhotoUp = new ReactiveVar null #, (a, b) ->
#  a?.src is b?.src


dropFile = (e, tmpl, options, onSuccess) ->
  e.preventDefault()
  evt = e.originalEvent or e
  files = evt.target.files or evt.dataTransfer?.files
  console.log("dropped", evt, files) if DEBUG
  if files?
    for file in files
      console.log("Droppecd file", file.name, file.size, file.type) if DEBUG
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
            
            PhotoUp.set(photo)

            options.callback?(null, photo)
            onSuccess?()

          , loadImage.options

      else
        toast("Cannot read #{file.type} file #{file.name}", 3000, 'red')

  false



Template.photoUp.onCreated ->
  PhotoUp.set(null)


Template.photoUp.onRendered ->
  console.log("turn off drag over") if DEBUG
  $(document).on "dragover", (e) ->
    #console.log("document dragover") if DEBUG
    e.preventDefault()
    false

  $(document).on "drop", (e) ->
    console.log("document drop") if DEBUG
    e.preventDefault()
    false


Template.photoUp.onDestroyed ->
  $(document).off "dragover"
  $(document).off "drop"
  PhotoUp.set(null)


Template.photoUp.helpers
  
  photo: ->
    PhotoUp.get()


  newDirections: ->
    @newDirections or "Drop image here"


Template.photoUp.events
  
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
    if not PhotoUp.get()?
      console.log("DROP on photoUp") if DEBUG
      dropFile(e, tmpl, @)


###########################
#
#  photoUpImagePreview
#


doJcrop = (tmpl) ->
  tmpl.jCrop = null
  console.log("doJcrop", tmpl.data.jCrop) if DEBUG
  options = _.defaults tmpl.data.jCrop or {},
    onSelect: (cords) ->
      tmpl.cropCords.set(cords)
    onRelease: ->
      tmpl.cropCords.set(null)

  tmpl.$('#image-preview').Jcrop options, ->
    console.log("Set crop", @, tmpl) if DEBUG
    tmpl.jCrop = @
  .parent().on "click", (event) ->
    event.preventDefault()


removeJcrop = (tmpl) ->
  console.log("removeJcrop", tmpl.jCrop) if DEBUG
  tmpl.jCrop?.destroy()
  tmpl.$('#image-preview')?.attr('style', '')
  tmpl.jCrop = null


Template.photoUpImagePreview.onCreated ->
  @originalPhoto = new ReactiveVar()
  @cropCords = new ReactiveVar(null)


Template.photoUpImagePreview.onRendered ->
  console.log("photoUpImagePreview onRendered", @)
  if @data?.crop
    doJcrop(@)


Template.photoUpImagePreview.helpers
  
  replaceDirections: ->
    @replaceDirections or "Drop new image to replace"


  noContent: ->
    if @showInfo or @showClear or Template.instance().cropCords?.get()? or Template.instance().originalPhoto?.get()?
      ""
    else
      "no-content"


  showAction: ->
    Template.instance().cropCords?.get()? or @showClear or Template.instance().originalPhoto?.get()?


  showReset: ->
    Template.instance().originalPhoto.get()?


  showCrop: ->
    @crop and Template.instance().cropCords?.get()?


  photo: ->
    #console.log('photo', PhotoUp.get()) if DEBUG
    PhotoUp.get()


  imgWidth: ->
    console.log("imgWidth", PhotoUp.get()?.img?.width, @minDisplayWidth) if DEBUG
    Math.max(PhotoUp.get().img.width, @minDisplayWidth or 200)


  # imgHeight: ->
  #   console.log("imgHeight", PhotoUp.get()?.img?.height, @minDisplayHeight, Template.instance()) if DEBUG
  #   Math.max(PhotoUp.get().img.height, @minDisplayHeight or 200, $('.photoUp #image-preview')?.height?())


Template.photoUpImagePreview.events

  'drop .dropbox': (e, tmpl) ->
    console.log("DROP on photoUpImagePreview") if DEBUG
    tmpl.originalPhoto.set(null)
    tmpl.cropCords?.set(null)
    #removeJcrop(tmpl)
    dropFile e, tmpl, @, =>
      if @crop
        removeJcrop(tmpl)
        Meteor.setTimeout ->
          doJcrop(tmpl)
        , 500


  'click .clear': (e, tmpl) ->
    PhotoUp.set(null)

  
  'click .reset': (e, tmpl) ->
    console.log("reset") if DEBUG
    PhotoUp.set(Template.instance().originalPhoto.get())
    @callback?(null, PhotoUp.get())
    Template.instance().originalPhoto.set(null)
    Meteor.setTimeout ->
      doJcrop(tmpl)
    , 500


  'click .crop': (e, tmpl) ->
    if PhotoUp.get()? and Template.instance().cropCords?.get()?
      cropCords = Template.instance().cropCords.get()
      photo =  loadImage.scale PhotoUp.get()
      if photo.newImage
        console.log("save original") if DEBUG
        tmpl.originalPhoto.set(photo)
      console.log("Crop Image", cropCords, photo) if DEBUG
      
      newImg = loadImage.scale photo.img,
        left: cropCords.x
        top: cropCords.y
        sourceWidth: cropCords.w
        sourceHeight: cropCords.h
        #minWidth: img.parent().width()
        canvas: true

      console.log("New Crop Image", newImg) if DEBUG
      newPhoto = _.extend {}, photo,
        img: newImg
        src: newImg.toDataURL()
        size: photo.src.length
        newImage: false
        
      removeJcrop(tmpl)
      Template.instance().cropCords.set(null)
      PhotoUp.set(newPhoto)
      @callback?(null, photo)


