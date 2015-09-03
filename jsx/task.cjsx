React = require 'react'
Sty = require './jsplumb_style.cjsx'
Helpers = require './task_helpers.cjsx'
TaskName = Helpers.TaskName
HelpButton = Helpers.HelpButton
RequireBox = Helpers.RequireBox
AddAnswer = Helpers.AddAnswer
Answers = require './answers.cjsx'
AnswerList = Answers.AnswerList
TypeColorSelect = Helpers.TypeColorSelect
$ = jQuery = require 'jquery'
require 'jquery-ui/resizable'

# Global value to track what the max z-index is
max_z = 0

# Make a task node
Task = React.createClass
  displayName: 'Task'

  getInitialState: ->
    if @props.type == 'drawing'
      @props.task.answers = @props.task.tools
      answers = (t.label for t in @props.task.tools)
      draw_types = (t.type for t in @props.task.tools)
      draw_colors = (t.color for t in @props.task.tools)
    else
      answers = (a.label for a in @props.task.answers)
      draw_types = []
      draw_colors = []
    if @props.task
      {
        subTask: false
        answers: answers
        draw_types: draw_types
        draw_colors: draw_colors
        answer_text: ''
        draw_type: 'point'
        draw_color: 'red'
        number: @props.task.answers.length
        help_text: @props.task.help
        question: if @props.task.type == 'drawing' then @props.task.instruction else @props.task.question
        task_number: @props.taskNumber
        required: @props.task.required
        task_init: true
        zIndex: @props.taskNumber + 1
        endpoints: []
        uuid: 0
        uuids: []
        type: @props.type
        plumbId: @props.plumbId
      }
    else
      {
        subTask: false
        answers: []
        draw_types: []
        draw_colors: []
        answer_text: ''
        draw_type: 'point'
        draw_color: 'red'
        number: 0
        help_text: ''
        question: ''
        task_number: @props.taskNumber
        required: false
        task_init: false
        zIndex: @props.taskNumber + 1
        endpoints: []
        uuid: 0
        uuids: []
        type: @props.type
        plumbId: @props.plumbId
      }

  # add endpoins to task and get uniuque id's for answer list if needed
  # grab values needed for resize and move events
  # hook up resize and move events
  componentDidMount: ->
    # set up some variables to use during resize events
    @me = React.findDOMNode(this)
    @width_min = parseFloat(window.getComputedStyle(@me)['min-width'])
    @width_max = parseFloat(window.getComputedStyle(@me)['max-width'])
    @bounding_rect = @me.getBoundingClientRect()
    # keep track of previous task and if it is a sub-tasks
    # @subTask = false
    @previousTask = null
    # make the node resizable using jQuery-ui
    resize_options =
      handles: 'e'
      start: @onResizeStart
      resize: @onResize
      stop: @onResizeStop
    jQuery.ui.resizable(resize_options, @me)
    # make node draggable using jsPlumb
    drag_options =
      handle: '.drag-handel'
      start: @onDrag
      stop: @props.onMove
    @props.jp.draggable(@props.plumbId, drag_options)
    # add an "input" endpoint
    ep = @props.jp.addEndpoint(@props.plumbId, Sty.commonT, {uuid: @props.plumbId})
    ep.canvas.style['z-index'] = @state.task_number + 1
    eps = [ep]
    # make sure answer endpoints are drawn *after* the div is draggable and has its endpoint
    if (@state.type != 'multiple') and (@state.task_init)
      # track uuid list manually since setState is called after the loop
      uuids = []
      uuid = 0
      for idx in [0...@state.answers.length]
        id = @getUuid(idx, uuid, uuids)
        uuids.push(id)
        uuid += 1
        switch @state.type
          when 'single' then ep = @props.jp.addEndpoint(id, Sty.commonA, {uuid: id})
          when 'drawing' then ep = @props.jp.addEndpoint(id, Sty.commonA_open, {uuid: id})
        ep.canvas.style['z-index'] = @state.task_number + 1
        eps.push(ep)
      @setUuid(null, uuid, uuids)
    if @state.type != 'single'
      ep = @props.jp.addEndpoint(@props.plumbId+'_name', Sty.commonA, {uuid: @props.plumbId + '_next'})
      ep.canvas.style['z-index'] = @state.task_number + 1
      eps.push(ep)
    @setState({task_init: false, endpoints: eps})
    return

  # when the node is removed clean up all endpoints
  componentWillUnmount: ->
    for ep in @state.endpoints
      @props.jp.deleteEndpoint(ep)
    return

  # Make sure workflow knows about updates
  # this funcion is ment to be called in setState commands
  workflowUpdate: ->
    if not @state.task_init
      @props.onUpdate(@state)

  # check if a string is just whitespace
  isEmptyStr: (str) ->
    str.replace(/^\s+|\s+$/g, '').length == 0

  # define some setters and getters
  #==========================

  # Keep track of unique uuids to use for each answer DOM element
  # These can't be re-used after removal, otherwise the endpoint will not draw in the right spot
  # This is a limitation of jsPlumb
  setUuid: (id, uuid, uuids) ->
    current_uuids = uuids ? @state.uuids.concat([id])
    current_uuid =  uuid ? @state.uuid + 1
    @setState({uuids: current_uuids, uuid: current_uuid})

  # Get a unique uuid for an answer based on its position in the answer list
  getUuid: (idx, uuid = @state.uuid, uuids = @state.uuids) ->
    # When loading with answsers make sure to use idx since setState is not called until after the loop
    if @state.task_init
      return @props.plumbId + '_answer_' + idx
    # if it is already in the list, use existing value
    if uuids[idx]?
      return @state.uuids[idx]
    # if not make a new unique one
    else
      return @props.plumbId + '_answer_' + uuid

  # add an endpoint to the list of endpoints
  pushEps: (ep) ->
    eps = @state.endpoints.concat([ep])
    @setState({endpoints: eps})

  # remove an endpoint from the list of endpoints (always remove the last one)
  removeEps: ->
    eps = @state.endpoints[...-1]
    current_uuids = @state.uuids[...-1]
    @setState({endpoints: eps})
    @setState({uuids: current_uuids})

  # get css style to use
  getStyle: ->
    style = @props.pos
    style['zIndex'] = @state.zIndex
    if @state.zIndex > max_z
      max_z = @state.zIndex
    style

  # get props to pass to AnswerList
  getInputs: ->
    inputs =
      type: @state.type
      answers: @state.answers
      uuid:
        set: @setUuid
        get: @getUuid
      taskInit: @state.task_init
      remove: @onRemove
      edit: @onEdit
      number: @state.task_number
    if @state.type != 'multiple'
      inputs['eps'] =
        add: @pushEps
        remove: @removeEps
        zIndex: @state.zIndex
        endpoints: @state.endpoints
    if @state.type == 'drawing'
      inputs['tools'] = @state.draw_types
      inputs['colors'] = @state.draw_colors
    inputs

  # set/un-set a sub-task flag
  setSubTask: (val, callback) ->
    if @state.type == 'drawing'
      # drawing tasks can't be sub-tasks
      return
    # don't do anything if the state does not change
    if val != @state.subTask
      if val
        # set the draw style for the endpiont and connections
        @state.endpoints[0]._jsPlumb.maxConnections = 1
        # do this loop backwards so disconnects happen first
        for ep, idx in @state.endpoints[1..] by -1
          ep.connectorStyle = Sty.commonA_open.connectorStyle
          ep.setPaintStyle(Sty.commonA_open.paintStyle)
          ep.setHoverPaintStyle(Sty.commonA_open.hoverPaintStyle)
          if idx > 0
            @props.jp.detachAllConnections(ep.elementId)
            ep.setVisible(false)
          # set style for any connectors already drawn
          for con in ep.connections
            con.setPaintStyle(Sty.commonA_open.connectorStyle)
            callback?(con.targetId, val)
      else
        # set the draw style for the endpiont and connections
        @state.endpoints[0]._jsPlumb.maxConnections = -1
        for ep, idx in @state.endpoints[1..]
          ep.connectorStyle = Sty.commonA.connectorStyle
          ep.setPaintStyle(Sty.commonA.paintStyle)
          ep.setHoverPaintStyle(Sty.commonA.hoverPaintStyle)
          # set style for any connectors already drawn
          if idx > 0
            ep.setVisible(true)
          for con in ep.connections
            con.setPaintStyle(Sty.commonA.connectorStyle)
            callback?(con.targetId, val)
      @setState({subTask: val})

  # define functions to take care of chaning data
  #====================================

  # Callback to take care of simple state changes
  onChange: (k, wf_update, e) ->
    # k is the state key to change
    # if wf_update is true add the wrokflowUpdate callback
    # e is the change event
    to_change = {}
    if e.target.type == 'checkbox'
      to_change[k] = e.target.checked
    else
      to_change[k] = e.target.value
    if wf_update
      @setState(to_change, @workflowUpdate)
    else
      @setState(to_change)

  # Callback to add a new answer to the list
  onAdd: (e) ->
    if not @isEmptyStr(@state.answer_text)
      current_answers = @state.answers.concat([@state.answer_text])
      if @state.type == 'drawing'
        current_draw_types = @state.draw_types.concat([@state.draw_type])
        current_draw_colors = @state.draw_colors.concat([@state.draw_color])
        @setState({answers: current_answers, number: current_answers.length, answer_text: '', draw_types: current_draw_types, draw_colors: current_draw_colors}, @workflowUpdate)
      else
        @setState({answers: current_answers, number: current_answers.length, answer_text: ''}, @workflowUpdate)

  # Callback to remove an asnwer from the list
  onRemove: (e) ->
    idx = +e.target.getAttribute('data-idx')
    current_answers = @state.answers
    current_answers.splice(idx, 1)
    if @state.type == 'drawing'
      current_draw_types = @state.draw_types
      current_draw_colors = @state.draw_colors
      current_draw_types.splice(idx, 1)
      current_draw_colors.splice(idx, 1)
      @setState({answers: current_answers, number: current_answers.length, draw_types: current_draw_types, draw_colors: current_draw_colors}, @workflowUpdate)
    else
      @setState({answers: current_answers, number: current_answers.length}, @workflowUpdate)

  # Callback when answer/tool is edited
  onEdit: () ->
    k = arguments[0]
    # need to check how many arguments it was called with
    # TypeColorSelect passes 3 arguments
    # The event is always last in the argument list
    if arguments.length == 2
      e = arguments[1]
    else
      e = arguments[2]
    current = @state[k]
    idx = +e.target.getAttribute('data-idx')
    current[idx] = e.target.value
    to_change = {}
    to_change[k] = current
    @setState(to_change, @workflowUpdate)

  # define functions to take care of moving and resizing
  #=========================================

  # Make sure element being dragged is on top layer
  onDrag: (e) ->
    if @state.zIndex < max_z
      max_z += 1
      ep.canvas.style['z-index'] = max_z for ep in @state.endpoints
      @setState({zIndex: max_z})

  # Callback when resize starts to recored current mouse positoin
  onResizeStart: (e) ->
    @bounding_rect = @me.getBoundingClientRect()
    @width = e.clientX
    return

  # Callback durring resize to move answer endpoints
  onResize: (e) ->
    w = e.clientX
    if (w != @width)
      delta = w - @width - 2
      new_width = @bounding_rect.width + delta
      if new_width < @width_min
        delta = @width_min - @bounding_rect.width
      else if new_width > @width_max
        delta = @width_max - @bounding_rect.width
      for ep in @state.endpoints[1...]
        offset = @props.jp.getOffset(ep.elementId)
        offset.left += delta
        @props.jp.repaint(ep.elementId,offset)
        @props.jp.dragManager.updateOffsets(@props.plumbId)
    return

  # Callback after resize to save endpoints' positions
  onResizeStop: (e) ->
    @bounding_rect = @me.getBoundingClientRect()
    for ep in @state.endpoints[1...]
      @props.jp.revalidate(ep.elementId, null, true)
    @props.onMove()
    return

  # Useful for debugging
  onClick: (e) ->
    console.log(@)

  # defind function to render each type of task
  #===================================

  # Draw task
  render: ->
    # the things that change based on task type
    box_class = 'box noselect '
    required_box = <RequireBox onChange={@onChange} required={@state.required} />
    type_color_select = <TypeColorSelect edit={false}  onChange={@onChange} drawType={@state.draw_type} drawColor={@state.draw_color} />
    switch @props.type
      when 'single'
        box_class += 'question-box'
        type_color_select = undefined
      when 'multiple'
        box_class += 'multi-box'
        type_color_select = undefined
      when 'drawing'
        box_class += 'drawing-box'
        required_box = undefined

    inputs = @getInputs()
    <div className={box_class} style={@getStyle()} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick} >
      <div className='drag-handel'>
        <span className='box-head noselect'>
          {@state.type.charAt(0).toUpperCase() + @state.type.substr(1)} {'(sub)' if @state.subTask}
        </span>
        <a className='close close-box noselect' onClick={@props.remove} data-wfkey={@props.wfKey}>&times;</a>
        <br />
      </div>
      <TaskName onChange={@onChange} question={@state.question} number={@props.taskNumber} plumbId={@props.plumbId} />
      <HelpButton help={@state.help_text} onChange={@onChange} />
      {required_box}
      <AnswerList jp={@props.jp} inputs={inputs} plumbId={@props.plumbId} />
      <AddAnswer boxState={@state} change={@onChange} add={@onAdd} number={@state.task_number} />
      {type_color_select}
    </div>
#

StartEndNode = React.createClass
  displayName: 'StartNode'

  getInitialState: ->
    {
      zIndex: 1
    }

  componentDidMount: ->
    @me = React.findDOMNode(this)
    @empty_style =
      left: @me.offsetLeft + 'px'
      top: @me.offsetTop + 'px'
    @me.style.left = @empty_style.left
    @me.style.top = @empty_style.top
    drag_options =
      start: @onDrag
      stop: @props.onMove
    @props.jp.draggable(@props.type, drag_options)
    switch @props.type
      when 'start' then ep = @props.jp.addEndpoint(@props.type, Sty.commonA, {uuid: @props.type})
      when 'end' then ep = @props.jp.addEndpoint(@props.type, Sty.commonT, {uuid: @props.type})
    ep.canvas.style['z-index'] = @state.zIndex
    @ep = ep

  moveMe: (pos, reset = false) ->
    if reset
      pos = @empty_style
    else
      pos =
        left: pos.left + ''
        top: pos.top + ''
    @me.style.left = if pos.left[-2..] == 'px' then pos.left else pos.left + 'px'
    @me.style.top = if pos.top[-2..] == 'px' then pos.top else pos.top + 'px'
    @props.jp.revalidate(@ep.elementId, null, true)

  onDrag: ->
    if @state.zIndex < max_z
      max_z += 1
      @ep.canvas.style['z-index'] = max_z
      @setState({zIndex: max_z})

  render: ->
    style =
      top: '50%'
      zIndex: @state.zIndex
    switch @props.type
      when 'start' then style['left'] = '0%'
      when 'end' then style['right'] = '0%'
    classString = 'box-end noselect ' + @props.type
    <div className={classString} id={@props.type} style={style}>
      {@props.type.charAt(0).toUpperCase() + @props.type.slice(1)}
    </div>
#

module.exports =
  Task: Task
  StartEndNode: StartEndNode
