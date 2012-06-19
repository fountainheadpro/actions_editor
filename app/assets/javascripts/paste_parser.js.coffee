class PasteParser

  waiting_attemps=20

  handlepaste: (elem, e) ->
    pasteData=build_paste_data(e)
    pasteData.waiting_attempts=20
    waitforpastedata elem, pasteData if pasteData?
    true

    #if e.preventDefault
    # e.stopPropagation()
    # e.preventDefault()
    # false
    #else
    # waitforpastedata elem, pasteData
    # true


  build_paste_data = (e) ->
    imageFilter = /^(?:image\/bmp|image\/cis\-cod|image\/gif|image\/ief|image\/jpeg|image\/jpeg|image\/jpeg|image\/pipeg|image\/png|image\/svg\+xml|image\/tiff|image\/x\-cmu\-raster|image\/x\-cmx|image\/x\-icon|image\/x\-portable\-anymap|image\/x\-portable\-bitmap|image\/x\-portable\-graymap|image\/x\-portable\-pixmap|image\/x\-rgb|image\/x\-xbitmap|image\/x\-xpixmap|image\/x\-xwindowdump)$/i
    pasteData=
     focusElement: window.getSelection().focusNode
     focusOffset: window.getSelection().focusOffset
     data: ""
     type: "text"
    cbd=e.originalEvent.clipboardData if e and e.originalEvent.clipboardData
    if cbd && cbd.getData
     if /text\/plain/.test(e.originalEvent.clipboardData.types)
      pasteData.data = e.originalEvent.clipboardData.getData("text/plain")
      pasteData.type='text'
     else if /text\/html/.test(e.originalEvent.clipboardData.types)
      pasteData.data = e.originalEvent.clipboardData.getData("text/html")
      pasteData.type='html'
     else if /Files/.test(e.originalEvent.clipboardData.types)  && imageFilter.test(cbd.items[0].type)
      reader=new FileReader()
      reader.readAsDataURL(e.originalEvent.clipboardData.items[0].getAsFile())
      pasteData.type='img_url'
      reader.onloadend=
       (event)->
        pasteData.data=event.target.result
    pasteData

  waitforpastedata = (elem, pasteData) ->
    if  pasteData.waiting_attempts<20 && pasteData.data.length>0
      tp=new TextProcessor()
      if (pasteData.type=='text' or pasteData.type=='html')
        tp.re_format(elem)
      else
        new_node=tp.build_image_from_paste(pasteData.data)
        processpaste(elem, pasteData, new_node)
    else
     #if pasteData.focusElement.nodeType==3
     # pasteData.focusElement.splitText(pasteData.focusOffset)
     if pasteData.waiting_attempts>0
       that =
        e: elem
        s: pasteData
       that.callself = ->
        waitforpastedata that.e, that.s
       pasteData.waiting_attempts=pasteData.waiting_attempts-1
       setTimeout that.callself, 20

  processpaste = (elem, pasteData, new_node) ->
    fe=pasteData.focusElement
    parent=fe.parentNode
    if fe==elem
      $(elem).append($(new_node))
    else if fe.nodeType==3
      newTextElement=pasteData.focusElement.splitText(pasteData.focusOffset)
      $(newTextElement).selectionStart=$(newTextElement).selectionEnd=1
      $(parent).insertAfter(newTextElement)
    else
      $(fe).after(new_node)

window.PasteParser = PasteParser