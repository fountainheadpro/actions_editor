String::endsWith = (suffix) ->
  @indexOf(suffix, @length - suffix.length) isnt -1

#String::trim = ->
#  @replace /^\s+|\s+$/g, ""

class TextProcessor

  urlPatternMatch=new RegExp()

  constructor: () ->
    c='[a-z][a-z0-9\\-+.]+://'
    #c='http?://'
    h='www\\d{0,3}[.]'
    b='[a-z0-9.\\-]+[.][a-z]{2,4}\\/'
    a='\\([^\\s()<>]+\\)'
    f='[^\\s()<>]+'
    e='[^\\s`!()\\[\\]{};:\'".,<>?]'
    fullregex='\\b('+'(?:'+c+'|'+h+'|'+b+')'+'(?:'+a+'|'+f+')*'+'(?:'+a+'|'+e+')'+')'
    #fullregex='(?:'+c+'|'+h+'|'+b+')'+'(?:'+a+'|'+f+')*'+'(?:'+a+'|'+e+')'
    #fullregex="(?:http?s?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])"
    urlPatternMatch=new RegExp(fullregex, 'gim')

  build_image_from_paste: (data) ->
    img=build_image_node(data)
    $(img.children().first()).on('image_uploaded',
      (e)->
        $(e.target).attr('src', e.link)
    )

  re_format: (node) ->
    re_format_internal(node) if node?

  #re_format_paste: (pasteData) ->


  is_ready_for_processing_text: (node, text) ->
    if $(node).html().indexOf(text) > 0
      matcing_text_node=$.grep(node.childNodes, (child)-> child.nodeType==3 && child.textContent==text)
    _.isEmpty(matcing_text_node)

  is_url = (text) ->
    return (text.match?) && (text.match(urlPatternMatch) != null)

  is_image= (text) ->
    return is_url(text) and (text.endsWith('.jpg') or text.endsWith('.jpeg') or text.endsWith('.png') or text.endsWith('.gpg'))

  re_format_internal= (node) ->
    children=node.childNodes
    if (children && children.length>0)
      _.each(children,
        (child) ->
          $(child).removeAttr('style')
          $(child).removeAttr('class')
          mark_processed(child)
          re_format_internal(child)
        )
    else
      format(node)

  format= (node) ->
    text=$(node).text()
    #avoid formatting empty text nodes
    return node if text.trim().length==0
    blocks=_.compact(text.split(urlPatternMatch))
    length=blocks.length
    #avoid formatting processed node
    return node if length==1 && is_processed(node)
    _.each(blocks,
      (block) ->
        $(node).before(process_block(block))
    )
    $(node).remove()

  process_block = (block) ->
    return null if (is_processed(block) or _.isEmpty(block))
    return block unless _.isString(block)
    if is_url(block)
      return build_url_node(block)
    return build_text_node(block)


  clean_up_html = (node) ->
    return if is_processed(node)
    unless ['img', 'ul', 'li', 'ol', 'div', 'span', 'strong'].indexOf(node.nodeName.toLowerCase()) > 0
      if node.childNodes && node.childNodes.length>0
        $(node).replaceWith(node.childNodes)
       else
        $(node).remove()
      return true
    else
      return false

  build_url_node = (url) ->
    wrupper_span=$(document.createElement('span'))
    wrupper_span.html("<img src='/images/icon_waiting.gif'/>")
    node=wrupper_span.children(":first")
    $.ajax(
      url: "/proxifier/"+encodeURIComponent(url)
      success: (data)->
        if data.type=='link'
          link=$(document.createElement('a'))
          link.attr('href',url)
          link.attr('target','_blank')
          mark_processed(link)
          $(link).html(data.title)
          replace_node(node, link)
        if data.type=='image'
          replace_node($(node), build_image_node(data.url))
        if data.type=='error'
          replace_node($(node), build_text_node(url))
      error: (error) ->
        replace_node(wrupper_span, build_text_node(url))
    )
    mark_processed(wrupper_span)

  replace_node = (node, processed_node) ->
    return unless processed_node?
    #have to do it this way to keep the cursor in the right place.
    $(node).before(processed_node)
    $(node).remove()

  build_image_node = (url) ->
    wrupper_div=$(document.createElement('div'))
    img=$(document.createElement('img'))
    img.attr('src',url)
    img.attr('max-width','100%')
    img.attr('max-height','100%')
    mark_processed(img)
    wrupper_div.append(img)
    mark_processed(wrupper_div)

  build_text_node = (text) ->
    node=$(document.createElement('span'))
    #text.replace('http://', "") if text.endsWith('http://')
    node.text(text)
    mark_processed(node)

  is_processed = (node) ->
    #node is processed if it's the only one text node in the processed span
    if node.nodeType == 3 && node.parentNode.childNodes.length==1
      return is_processed(node.parentNode)
    else
      if node && node.getAttribute?
        node.getAttribute('_action')=='1'
      else
        false

  mark_processed=(block) ->
    $(block).attr('_action',1)
    block

  #to-do need to figure out the right way of processing html pastes
  clean_up = (html) ->
    rv=""
    if html?
      hidden_div = $(document.createElement("div")).html(html)
      children=hidden_div.children()
      for child in children
        do (child) ->
          $(child).replaceWith(document.createTextNode(streap_off_tags($(child).html()))) unless is_processed(child)
      rv=hidden_div.html()
      hidden_div.remove() if hidden_div?
      rv

  streap_off_tags = (html) ->
    hidden_div=$(document.createElement('div'))
    hidden_div.html(html)
    text = hidden_div.text()
    hidden_div.remove() if hidden_div?
    text


@.TextProcessor=TextProcessor