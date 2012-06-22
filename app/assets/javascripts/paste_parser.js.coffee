class PasteParser

  waiting_attemps=20

  handlepaste: (elem, e) ->
    pasteData=build_paste_data(e)
    pasteData.is_ready=false
    waitforpastedata elem, pasteData if pasteData?
    true


  build_paste_data = (e) ->
    imageFilter = /^(?:image\/bmp|image\/cis\-cod|image\/gif|image\/ief|image\/jpeg|image\/jpeg|image\/jpeg|image\/pipeg|image\/png|image\/svg\+xml|image\/tiff|image\/x\-cmu\-raster|image\/x\-cmx|image\/x\-icon|image\/x\-portable\-anymap|image\/x\-portable\-bitmap|image\/x\-portable\-graymap|image\/x\-portable\-pixmap|image\/x\-rgb|image\/x\-xbitmap|image\/x\-xpixmap|image\/x\-xwindowdump)$/i
    pasteData=
     focusElement: window.getSelection().focusNode
     focusOffset: window.getSelection().focusOffset
     data: ""
     type: "text"
    cbd=e.originalEvent.clipboardData if e and e.originalEvent.clipboardData
    if cbd && cbd.getData
     if  /text\/html/.test(e.originalEvent.clipboardData.types)
       pasteData.data = e.originalEvent.clipboardData.getData("text/html")
       pasteData.type='html'
     else if /text\/plain/.test(e.originalEvent.clipboardData.types)
       pasteData.data = e.originalEvent.clipboardData.getData("text/plain")
       pasteData.type='text'
     else if /Files/.test(e.originalEvent.clipboardData.types)  && imageFilter.test(cbd.items[0].type)
      reader=new FileReader()
      reader.readAsDataURL(e.originalEvent.clipboardData.items[0].getAsFile())
      pasteData.type='image'
      reader.onloadend=
       (event)->
        pasteData.data=event.target.result
    pasteData

  waitforpastedata = (elem, pasteData) ->
    if  pasteData.is_ready && pasteData.data.length>0
      tp=new TextProcessor()
      if (pasteData.type=='text')
        if pasteData.focusElement.nodeType==3
          new_text_element=pasteData.focusElement.splitText(pasteData.focusOffset)
          new_text_element.splitText(pasteData.data.length)
        tp.re_format(pasteData.focusElement.parentNode)
      if (pasteData.type=='html')
        tp.re_format(pasteData.focusElement.parentNode)
      if (pasteData.type=='image')
        new_node=tp.build_image_from_paste(pasteData.data)
        processpaste(elem, pasteData, new_node)
    else
     unless pasteData.is_ready
       that =
        e: elem
        s: pasteData
       that.callself = ->
        waitforpastedata that.e, that.s
       pasteData.is_ready=true
       setTimeout that.callself, 20

  processpaste = (elem, pasteData, new_node) ->
    fe=pasteData.focusElement
    parent=fe.parentNode
    if fe==elem
      $(elem).append($(new_node))
    else if fe.nodeType==3
      pasteData.focusElement.splitText(pasteData.focusOffset)
      if fe.nextSibling?
        $(fe.nextSibling).before(new_node)
      else
        parent.appendChild(new_node)
    else
      $(fe).before(new_node)

window.PasteParser = PasteParser