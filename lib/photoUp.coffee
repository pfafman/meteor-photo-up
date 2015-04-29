
DEBUG = false

CORDOVA_PROMPT = true

iOS: ->
  window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)

# Global  arrrggg
@PhotoUp = new ReactiveVar null



aspectOk = ->
  options = PhotoUp.get().options
  if options.requiredAspectRatio
    aspectRatio = PhotoUp.get().width/PhotoUp.get().height
    diff = options.requiredAspectRatio - aspectRatio
    if diff > 0.01
      return false
  true


imageIsValid = ->
  aspectOk()


processImage = (fileOrSrc, tmpl, options, onSuccess) ->
  console.log("processImage", fileOrSrc?.length)
  loadImage.options = _.defaults options.loadImage or {},
    canvas: true
    orientation: fileOrSrc?.exif?.get?('Orientation') or 1

  loadImage fileOrSrc, (img) ->
    console.log("processImage loadImage", img, img.src?.length)
    photo =
      name: fileOrSrc?.name?.split('.')[0] or ''
      filesize: fileOrSrc?.size or img.toDataURL?().length or img.src?.length
      img: img
      width: img.width
      height: img.height
      src: img.toDataURL?() or img.src
      size: img.toDataURL?().length or img.src?.length
      newImage: true
      orientation: data?.exif?.get?('Orientation') or 1
      options: options
    
    PhotoUp.set(photo)

    if imageIsValid()
      options.callback?(null, photo)
    
    onSuccess?()


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
              width: img.width
              height: img.height
              src: img.toDataURL()
              size: img.toDataURL().length
              newImage: true
              orientation: data?.exif?.get?('Orientation') or 1
              options: options
            
            PhotoUp.set(photo)

            if imageIsValid()
              options.callback?(null, photo)
            onSuccess?()

          , loadImage.options

      else
        Materialize.toast(T9n.get("Cannot read") + " #{file.type} " + T9n.get('file') + " #{file.name}", 3000, 'red')

  false



Template.photoUp.onCreated ->
  if @data?.photo?
    @data.photo.img = new Image(@data.photo.width, @data.photo.height)
    @data.photo.img.src = @data.photo.src
  PhotoUp.set(@data?.photo)


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
    @newDirections or T9n.get("Drop image here")


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


  # Trigger file dialog.  Need way to do this again if we selected an image already
  'click .photo-in': (e, tmpl) ->
    console.log('click photo-in') if DEBUG
    e.preventDefault()
    if Meteor.isCordova and CORDOVA_PROMPT
      if MaterializeModal?.confirm?
        MaterializeModal.confirm
          title: T9n.get "Use Camera?"
          message: ''
          closeLabel: T9n.get 'No'
          submitLabel: T9n.get 'Yes'
          callback: (useCamera) =>
            
            options =
              width: @desiredWidth or 600
              height: @desiredHeight or 400
              quality: 100
            
            if not useCamera
              options.sourceType = Camera.PictureSourceType.PHOTOLIBRARY
            
            MeteorCamera.getPicture options, (error, src) =>
              if error
                Materialize.toast("#{error.reason}", 4000)
              else if src
                processImage(src, tmpl, @)
      else
        # Confirm is an ugly UI!
        useCamera = confirm(T9n.get "Use camera?")
        options =
          width: @desiredWidth or 600
          height: @desiredHeight or 400
          quality: 100
        
        if not useCamera
          options.sourceType = Camera.PictureSourceType.PHOTOLIBRARY
        
        MeteorCamera.getPicture options, (error, src) =>
          if error
            Materialize.toast("#{error.reason}", 4000)
          else if src
            processImage(src, tmpl, @)


    else
      tmpl.$("#file-uploader").trigger('click')


  'change #file-uploader': (e, tmpl) ->
    e.preventDefault()
    if not PhotoUp.get()?
      console.log("FILE LOAD on photoUp") if DEBUG
      dropFile(e, tmpl, @)


###########################
#
#  photoUpImagePreview
#


doJcrop = (tmpl) ->
  tmpl.jCrop = null
  console.log("doJcrop", tmpl, tmpl.data.jCrop) if DEBUG

  img = tmpl.$('#image-preview')[0]
  if tmpl.data.jCrop?.aspectRatio
    initialHeight = (img.width-60)/tmpl.data.jCrop.aspectRatio - 30
  else
    initialHeight = img.height-30
  setSelect = [30, 30, img.width-30, initialHeight]
        
  options = _.defaults tmpl.data.jCrop or {},
    setSelect: setSelect
    onSelect: (cords) ->
      console.log("jcrop on select", cords, tmpl.cropCords) if DEBUG
      tmpl.cropCords.set(null)
      tmpl.cropCords.set(cords)
    onRelease: ->
      console.log("jcrop on release") if DEBUG
      tmpl.cropCords.set(null)
    #onChange: (cords) ->
    #  console.log("jcrop on change", cords)

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
  console.log("photoUpImagePreview onCreated") if DEBUG
  @originalPhoto = new ReactiveVar()
  @cropCords = new ReactiveVar(null)


Template.photoUpImagePreview.onRendered ->
  console.log("photoUpImagePreview onRendered", @)
  if @data?.crop
    doJcrop(@)


Template.photoUpImagePreview.helpers
  
  replaceDirections: ->
    replaceDirections = "Drop new image to replace"
    if @crop
      replaceDirections += " or crop this image"
    T9n.get replaceDirections
    @replaceDirections or replaceDirections


  fixMaxWidth: ->
    if Meteor.isCordova
      "fix-width"


  noContent: ->
    if @showInfo or @showClear or Template.instance().cropCords?.get()? or Template.instance().originalPhoto?.get()?
      ""
    else
      "no-content"

  filesize: ->
    (PhotoUp.get().filesize/1000).toFixed(0)


  photosize: ->
    (PhotoUp.get().size/1000).toFixed(0)


  badAspectRatio: ->
    if not aspectOk(@)
      "bad-aspect-ratio"
    

  showAction: ->
    console.log("showAction", Template.instance().cropCords.get()) if DEBUG
    Template.instance().cropCords.get()? or @showClear or Template.instance().originalPhoto?.get()?


  showReset: ->
    Template.instance().originalPhoto.get()?


  showCrop: ->
    console.log("showCrop", @crop, Template.instance().cropCords.get()) if DEBUG
    @crop and Template.instance().cropCords.get()?


  photo: ->
    #console.log('photo', PhotoUp.get()) if DEBUG
    PhotoUp.get()


  imgWidth: ->
    console.log("imgWidth", PhotoUp.get()?.width, @minDisplayWidth) if DEBUG
    width = Math.max(PhotoUp.get().width, @minDisplayWidth or 200)
    if @maxDisplayWidth? and width > @maxDisplayWidth
      @maxDisplayWidth
    else
      width

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
    e.preventDefault()
    event.stopPropagation()
    if PhotoUp.get()? and Template.instance().cropCords?.get()?
      cropCords = Template.instance().cropCords.get()
      #photo =  loadImage.scale PhotoUp.get()
      photo = PhotoUp.get()
      if photo.newImage
        console.log("save original") if DEBUG
        tmpl.originalPhoto.set(photo)
      
      console.log("Crop Image", cropCords, PhotoUp.get()) if DEBUG
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
        width: newImg.width
        height: newImg.height
        src: newImg.toDataURL()
        size: newImg.toDataURL().length
        newImage: false
        
      removeJcrop(tmpl)
      Template.instance().cropCords.set(null)
      PhotoUp.set(newPhoto)
      if imageIsValid()
        @callback?(null, newPhoto)


