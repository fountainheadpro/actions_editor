#  Project: action editor
#  Description: Simple text editor for action description. Includes link parsing and lookups.
#  Author: Sergey Zelvenskiy
#  License: MIT





(($, window) ->
  # window is passed through as local variable rather than global
  # as this (slightly) quickens the resolution process and can be more efficiently
  # minified (especially when both are regularly referenced in your plugin).

  # Create the defaults once
  pluginName = 'action_editor'
  document = window.document
  defaults =
    property: 'value'

  # The actual plugin constructor
  class Plugin
    constructor: (@el, options) ->
      # jQuery has an extend method which merges the contents of two or
      # more objects, storing the result in the first object. The first object
      # is generally empty as we don't want to alter the default options for
      # future instances of the plugin
      @options = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @init()

    init: ->
      $(@el).on("paste", format)
      $(@el).on("keyup", handle_key_up)


    handle_key_up=  (e) ->

      event_map={}
      event_map[$.ui.keyCode.DOWN] = "jump_down"
      event_map[$.ui.keyCode.UP] = "jump_up"

      memorize_position= ()=>
        $(@).data('selection_offset',window.getSelection().anchorOffset)
        $(@).data('selection_node',window.getSelection().anchorNode)
        #console.log "memorized_selection:"+$(@).data('selection_offset')

      position_not_changed= ()=>
          selection_offset =  $(@).data('selection_offset')
          selection_node =  $(@).data('selection_node')
          #console.log "same position:"+selection_offset
          rv = selection_offset? && selection_node? && (selection_node is window.getSelection().anchorNode) &&
          (selection_offset == window.getSelection().anchorOffset)
          #console.log 'same postion:'+rv
          return rv

      if _.has(event_map,event.keyCode)
        if  position_not_changed()
          e.preventDefault()
          $(@).trigger(event_map[event.keyCode])
        else
          memorize_position()
      return

    format= (e)->
      pp=new PasteParser()
      pp.handlepaste(@,e)



  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(this, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
)(jQuery, window)