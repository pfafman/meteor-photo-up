
DEBUG = true


iOS: ->
  window.navigator?.platform? and (/iP(hone|od|ad)/).test(window.navigator.platform)


Template.photoUp.onCreated ->
  @photo = new ReactiveVar()
  @processing = new ReactiveVar(null)
  @cropCords = new ReactiveVar(null)
  #@crop = new ReactiveVar(null)

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

              if options.crop
                console.log("Jcrop") if DEBUG
                tmpl.$('#image-preview').Jcrop
                  onSelect: (cords) ->
                    tmpl.cropCords.set(cords)
                  onRelease: ->
                    tmpl.cropCords.set(null)
                , ->
                  console.log("Set crop", @) if DEBUG
                  #tmpl.crop.set(@)
                  tmpl.photo.set(@)
                  options.callback?(null, @)
                .parent().on "click", (event) ->
                  event.preventDefault()

              else

                options.callback?(null, photo)

            , loadImage.options

        else
          toast("Cannot read #{file.type} file #{file.name}", 3000, 'red')

    false




