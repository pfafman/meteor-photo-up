
DEBUG = false

CORDOVA_PROMPT = true


# Global  arrrggg
@PhotoUp = new ReactiveVar(null)

PhotoUpCropCords = new ReactiveVar(null)

#####################
# Functions
#

# Global Helper
PhotoUp.DataURItoBlob = (dataURI) ->
  binary = atob(dataURI.split(',')[1])
  array = []
  i = 0
  while i < binary.length
    array.push binary.charCodeAt(i)
    i++
  new Blob([ new Uint8Array(array) ], type: 'image/png')


PhotoUp.Scale = (img, options) ->
  console.log("PhotoUp.Scale", options) if DEBUG
  loadImage.scale(img, options)


iOS: ->
  window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)


aspectOk = ->
  options = PhotoUp.get().options
  if options?.requiredAspectRatio
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
    canvas: false
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
      if file.type.indexOf("image") is 0

        loadImage.parseMetaData file, (data) ->

          loadImage.options = _.defaults options.loadImage or {},
            canvas: true
            orientation: data?.exif?.get?('Orientation') or 1

          loadImage file, (img) ->
            console.log("dropFile loadImage callback img", img, "file", file) if DEBUG
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

            if file.type.match('svg') and FileReader?
              console.log("File is SVG image get content ...")

              photo.svg = new Blob([file], type: file.type)
              photo.svg.name = file.name.split('.')[0]

              # reader = new FileReader()

              # reader.onload = ((theFile) ->
              #   (evt) ->
              #     console.log("fileReader file", theFile, evt)

              #     photo.svg =
              #       size: theFile.size
              #       content: evt?.target?.result
              #     PhotoUp.set(photo)
              #     if imageIsValid()
              #       options.callback?(null, photo)
              #     onSuccess?()
              # ) (file)

              # reader.readAsText(file)

            
            PhotoUp.set(photo)

            if imageIsValid()
              options.callback?(null, photo)
            onSuccess?()

          , loadImage.options

        


      else
        Materialize.toast(T9n.get("Cannot read") + " #{file.type} " + T9n.get('file') + " #{file.name}", 3000, 'red')

  false



# Preview Functions

doJcrop = (tmpl) ->
  console.log("doJcrop", tmpl) if DEBUG
  tmpl.jCrop?.release?()
  tmpl.jCrop?.destroy?()
  tmpl.jCrop = null
  console.log("doJcrop", tmpl, tmpl.data.jCrop) if DEBUG

  img = tmpl?.$('#image-preview')?[0]
  if tmpl.data.autoSelectOnJcrop or Meteor.isCordova
    if tmpl.data.jCrop?.aspectRatio
      initialHeight = (img.width-60)/tmpl.data.jCrop.aspectRatio - 30
    else
      initialHeight = img.height-30
    setSelect = [30, 30, img.width-30, initialHeight]
        
  options = _.defaults tmpl.data.jCrop or {},
    setSelect: setSelect
    onSelect: (cords) ->
      console.log("jcrop on select", cords, tmpl.cropCords) if DEBUG
      #tmpl.cropCords.set(null)
      tmpl.cropCords.set(cords)
      PhotoUpCropCords.set(cords)
      console.log("jcrop on select: new cropCords", tmpl.cropCords.get()) if DEBUG
    onRelease: ->
      console.log("jcrop on release") if DEBUG
      tmpl.cropCords.set(null)
      PhotoUpCropCords.set(null)
    #onChange: (cords) ->
    #  console.log("jcrop on change", cords)

  tmpl.$('#image-preview').Jcrop options, ->
    console.log("Set crop", @, tmpl, tmpl.cropCords.get()) if DEBUG
    tmpl.jCrop = @
  .parent().on "click", (event) ->
    event.preventDefault()


removeJcrop = (tmpl) ->
  console.log("removeJcrop", tmpl.jCrop) if DEBUG
  try
    tmpl.jCrop?.destroy()
    tmpl.$('#image-preview')?.attr('style', '')
    tmpl.jCrop = null
  catch error
    console.log("removeJcrop error", error)

#
###########################


###########################
#  photoUp Template
#


Template.photoUp.onCreated ->
  if @data?.photo?
    @data.photo.img = new Image(@data.photo.width, @data.photo.height)
    @data.photo.img.src = @data.photo.src
  console.log("photoUp onCreated", @data?.photo) if DEBUG
  PhotoUp.set(@data?.photo)

Template.photoUp.onRendered ->
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


  newImage: ->
    @newImage or '<i class="material-icons">insert_photo</i>'


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
          callback: (error, rtn) =>
            if error
              Materialize.toast("#{error.reason}", 4000)
            else
              options =
                width: @desiredWidth or 600
                height: @desiredHeight or 400
                quality: 100
              
              if not rtn.submit
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


#
######################################################


######################################################
#
#  photoUpImagePreview
#



Template.photoUpImagePreview.onCreated ->
  console.log("photoUpImagePreview onCreated", @cropCords) if DEBUG
  @originalPhoto = new ReactiveVar(null)
  @cropCords = new ReactiveVar(null)
  PhotoUpCropCords.set(null)


Template.photoUpImagePreview.onRendered ->
  console.log("photoUpImagePreview onRendered", @) if DEBUG
  if @data?.crop
    doJcrop(@)


Template.photoUpImagePreview.onDestroyed ->
  console.log("photoUpImagePreview onDestroyed") if DEBUG
  PhotoUp.set(null)
  #@jCrop.destroy()
  @originalPhoto.set(null)
  @cropCords.set(null)
  PhotoUpCropCords.set(null)



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
    if @showInfo or @showClear or Template.instance().originalPhoto?.get()? or PhotoUpCropCords.get()? # Template.instance().cropCords?.get()? 
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
    console.log("showAction cropCords:", Template.instance().cropCords, Template.instance().cropCords.get()) if DEBUG
    @showClear or Template.instance().originalPhoto?.get()? or PhotoUpCropCords.get()? # Template.instance().cropCords?.get()? 


  showReset: ->
    Template.instance().originalPhoto.get()?


  showCrop: ->
    console.log("showCrop", @crop, Template.instance().cropCords.get(), PhotoUpCropCords.get()) if DEBUG
    @crop and PhotoUpCropCords.get()? #Template.instance().cropCords.get()?


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

  'dragover .dropbox': (e, tmpl) ->
    console.log("Drag over") if DEBUG
    # if PhotoUp.get()
    #   tmpl.jCrop?.destroy?()
    #   PhotoUp.set(null)


  'drop .dropbox': (e, tmpl) ->
    console.log("DROP on photoUpImagePreview") if DEBUG
    
    # Clear it
    #PhotoUp.set(null)
    #removeJcrop(tmpl)
    
    tmpl.originalPhoto.set(null)
    tmpl.cropCords?.set(null)
    PhotoUpCropCords.set(null)

    dropFile e, tmpl, @, =>
      if @crop
        removeJcrop(tmpl)
        Meteor.setTimeout ->
          doJcrop(tmpl)
        , 200


  'click .clear': (e, tmpl) ->
    console.log("clear", tmpl.jCrop) if DEBUG
    tmpl.jCrop?.destroy?()
    PhotoUp.set(null)

  
  'click .reset': (e, tmpl) ->
    console.log("reset") if DEBUG
    PhotoUp.set(tmpl.originalPhoto.get())
    @callback?(null, PhotoUp.get())
    tmpl.originalPhoto.set(null)
    Meteor.setTimeout ->
      doJcrop(tmpl)
    , 500


  'click .crop': (e, tmpl) ->
    e.preventDefault()
    e.stopPropagation()
    if PhotoUp.get()? and PhotoUpCropCords.get()? # tmpl.cropCords?.get()?
      cropCords = PhotoUpCropCords.get() # tmpl.cropCords.get()
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
        
      console.log("Remove Crop") if DEBUG
      removeJcrop(tmpl)
      tmpl.cropCords.set(null)
      PhotoUpCropCords.set(null)

      PhotoUp.set(newPhoto)
      if imageIsValid()
        @callback?(null, newPhoto)

#
################################


