React = require 'react'
Input = require 'react-bootstrap/lib/Input'
Button = require 'react-bootstrap/lib/Button'
ButtonGroup = require 'react-bootstrap/lib/ButtonGroup'
Glyphicon = require 'react-bootstrap/lib/Glyphicon'
OverlayTrigger = require 'react-bootstrap/lib/OverlayTrigger'
Popover = require 'react-bootstrap/lib/Popover'
Row = require 'react-bootstrap/lib/Row'
Col = require 'react-bootstrap/lib/Col'
MarkdownIt = require 'markdown-it'
Ex1 = require './test_workflow_load.js'
Ex2 = require './test_workflow_load_gz.js'
$ = jQuery = require 'jquery'
require 'jquery-ui/resizable'

md = MarkdownIt({breaks: true})
  .use(require 'markdown-it-emoji')
  .use(require 'markdown-it-sub')
  .use(require 'markdown-it-sup')

# need to make a new jsPlumb instance to work with
jp = jsPlumb.getInstance()

# define the styles for various jsPlumb elements
connectorHoverStyle =
  lineWidth: 3
  strokeStyle: "#888"
  outlineWidth: 1.5
  outlineColor: "white"
#

endpointHoverStyle =
  fillStyle: "#888"
#

connectorPaintStyle =
  lineWidth: 3
  strokeStyle: "#000"
  joinstyle: "round"
  outlineColor: "white"
  outlineWidth: 1.5
#

commonA =
  connector: [ "Flowchart", { stub: 30, cornerRadius: 5, alwaysRespectStubs: false, midpoint: 0.5 } ]
  #connector: ["Straight"]
  #connectior: ["Bezier", { curviness: 150 }]
  #connectior: ["State Machine"]
  anchor: "Right"
  isSource: true
  endpoint: "Dot"
  connectorStyle: connectorPaintStyle
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  paintStyle:
    fillStyle: "#000"
    radius: 5
#

commonT =
  anchor: "Left"
  isTarget: true
  endpoint: "Dot"
  maxConnections: -1
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  dropOptions: { hoverClass: "hover", activeClass: "active" }
  paintStyle:
    fillStyle: "#000"
    radius: 7
#

# Render the task name box at the top of the node
TaskName = React.createClass
  displayName: 'TaskName'

  render: ->
    task_number = 'T ' + @props.number
    style =
      'zIndex': 'inherit'
    <div className='task' id={@props.plumbId + '_name'}>
      <Input className='question' type='textarea' onChange={@props.nameMe} value={@props.question} addonBefore={task_number} style={style} />
    </div>
#

# Add a button that brings up a popover where the user can add "help text" to the node
HelpButton = React.createClass
  displayName: 'HelpButton'

  closeHelp: ->
    @refs.help_popover.toggle()

  render: ->
    overlay =
      <Popover className='help-popover' title='Help text'>
        <Input className='help-text' type='textarea' onChange={@props.setHelp} rows=5 value={@props.help} />
        <Button onClick={@closeHelp} block>Save</Button>
      </Popover>

    <OverlayTrigger ref='help_popover' trigger='click' placement='bottom' overlay={overlay}>
      <Button className='add-help' bsSize="xsmall">Help Text</Button>
    </OverlayTrigger>
#

# Add a checkbox for making a task "required"
RequireBox = React.createClass
  displayName: 'RequireBox'

  render: ->
    <span className='req'>
      <Input className='required-check'  type='checkbox' onChange={@props.setReq} checked={@props.required} label='Required' bsSize='small' />
    </span>
#

# Add a box at the bottom to allow the user to make a new answer/tool for the task
AddAnswer = React.createClass
  displayName: 'AddAnswer'

  render: ->
    button = <Button className='add-answer' onClick={@props.add}>+</Button>
    before = 'A '+@props.boxState.number
    style =
      'zIndex': 'inherit'
    <div className='answer-add'>
      <Input className='answer-input' type='textarea' value={@props.boxState.answer_text} onChange={@props.change} addonBefore={before} buttonAfter={button} style={style} />
    </div>
#

# Styling for the answers within the list
AnswerItem = React.createClass
  displayName: 'AnswerItem'

  componentDidMount: ->
    # only add endpoints *after* the parent div is draggable (order matters here)!
    if (not @props.inputs.task_init) and (@props.inputs.type == 'single')
      ep = jp.addEndpoint(@props.inputs.listId, commonA, {uuid: @props.inputs.listId})
      @props.inputs.setUuid(@props.inputs.listId)
      ep.canvas.style['z-index'] = @props.eps.zIndex
      @props.eps.add(ep)
      jp.revalidate(ep.elementId, null, true)
      jp.dragManager.updateOffsets(@props.inputs.plumbId)
    return

  componentWillUnmount: ->
    # properly remove the endpoint and detach all connectors for the task
    if (@props.inputs.type == 'single')
      listId_split = @props.inputs.listId.split('_')
      base = listId_split[...-1].join('_') + '_'
      #jp.deleteEndpoint(@props.inputs.listId, false)
      jp.removeAllEndpoints(@props.inputs.listId)
      [..., ep] = @props.eps.endpoints
      jp.dragManager.endpointDeleted(ep)
      for ep in @props.eps.endpoints[1...]
        jp.detachAllConnections(ep.elementId)
      @props.eps.remove()
    return

  # check if a string is just whitespace
  isEmptyStr: (str) ->
    str.replace(/^\s+|\s+$/g, '').length == 0

  render: ->
    closeMe = =>
      @refs[@props.inputs.refMe].toggle()

    if @props.inputs.type == 'drawing'
      overlay =
        <Popover className='edit-popover' title='Edit Answer'>
          <Input className='help-text' type='textarea' onChange={@props.inputs.edit} data-idx={@props.inputs.idx} rows=5 value={@props.inputs.answer} />
          <TypeColorSelect nopad=true onDrawType={@props.inputs.editDrawType} onDrawColor={@props.inputs.editDrawColor} drawType={@props.inputs.tool} drawColor={@props.inputs.color} idx={@props.inputs.idx} />
          <Button onClick={closeMe} block>Save</Button>
        </Popover>
    else
      overlay =
        <Popover className='edit-popover' title='Edit Answer'>
          <Input className='help-text' type='textarea' onChange={@props.inputs.edit} data-idx={@props.inputs.idx} rows=5 value={@props.inputs.answer} />
          <Button onClick={closeMe} block>Save</Button>
        </Popover>

    if not @isEmptyStr(@props.inputs.text)
      text = {__html: md.render(@props.inputs.text)}
    else
      # if input is just whitespace make sure something is rendered
      text = {__html: '&nbsp;'}

    if @props.inputs.type == 'drawing'
      lab = 'T '
      tools = @props.inputs.tool + ', ' + @props.inputs.color
    else
      lab = 'A '
      tools = ''

    <li className='answer-item' id={@props.inputs.listId}>
      {lab + @props.inputs.idx + ': ' + tools}
      <a className='close' onClick={@props.inputs.remove} data-idx={@props.inputs.idx}>&times;</a>
      <OverlayTrigger ref={@props.inputs.refMe} trigger='click' placement='right' overlay={overlay}>
        <Glyphicon className='edit-icon' glyph='pencil' />
      </OverlayTrigger>
      <div className='lab' dangerouslySetInnerHTML={text}></div>
    </li>
#

# Handel the styling for the full answer list
AnswerList = React.createClass
  displayName: 'Answer'

  getInitialState: ->
    {removing: false}

  remove: (e) ->
    # trigger the remove envet for componentDidUpdate
    @setState({removing: true})
    @props.inputs.remove(e)

  componentDidUpdate: ->
    if (@state.removing) and (@props.inputs.type == 'single')
      # since jsPlumb's draggable cache's the old positions of the nodes update all offsets by hand
      for ep in @props.inputs.eps.endpoints[1...]
        # recaculate the node position based on the DOM element
        jp.revalidate(ep.elementId, null, true)
      # tell jsPlumb's dragManager to update the offsets
      jp.dragManager.updateOffsets(@props.plumbId)
      @setState({removing: false})

  createAnswer: (idx, text, N, getUuid) ->
    inputs =
      N: N
      idx: idx
      listId: getUuid(idx)
      remove: @remove
      refMe: 'edit_answer_'+idx
      text: text
      answer: @props.inputs.answers[idx]
      edit: @props.inputs.edit
      task_init: @props.inputs.taskInit
      setUuid: @props.inputs.uuid.set
      type: @props.inputs.type
      plumbId: @props.plumbId
    if @props.inputs.type == 'drawing'
      inputs.tool = @props.inputs.tools[idx]
      inputs.color = @props.inputs.colors[idx]
      inputs.editDrawType = @props.inputs.editDrawType
      inputs.editDrawColor = @props.inputs.editDrawColor

    <AnswerItem key={'AI_' + idx} inputs={inputs} eps={@props.inputs.eps} />

  render: ->
    N = @props.inputs.answers.length
    ul_id = @props.plumbId + '_answers'
    <ul className='list-unstyled' id={ul_id}>
      {@createAnswer(idx, text, N, @props.inputs.uuid.get) for text, idx in @props.inputs.answers}
    </ul>
#

TypeColorSelect = React.createClass
  dispalyName: 'TypeColorSelect'

  render: ->
    if @props.nopad
      s1 =
        paddingLeft: 0
      s2 =
        paddingRight: 0
    else
      s1 = {}
      s2 = {}
    <Row className='select-row'>
      <Col xs={6} className='type-select' style={s1}>
        <Input type='select' onChange={@props.onDrawType} value={@props.drawType} data-idx={@props.idx}>
          <option value='point'>point</option>
          <option value='line'>line</option>
          <option value='polygon'>polygon</option>
          <option value='rectangle'>rectangle</option>
          <option value='circle'>circle</option>
          <option value='ellipse'>ellipse</option>
        </Input>
      </Col>
      <Col xs={6} className='color-select' style={s2}>
        <Input type='select' onChange={@props.onDrawColor} value={@props.drawColor} data-idx={@props.idx}>
          <option value='red'>red</option>
          <option value='yellow'>yellow</option>
          <option value='green'>green</option>
          <option value='blue'>blue</option>
          <option value='cyan'>cyan</option>
          <option value='magenta'>magenta</option>
          <option value='black'>black</option>
          <option value='white'>white</option>
        </Input>
      </Col>
    </Row>
#

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
        answers: answers
        draw_types: draw_types
        draw_colors: draw_colors
        answer_text: ''
        draw_type: 'point'
        draw_color: 'red'
        number: @props.task.answers.length
        help_text: @props.task.help
        question: @props.task.question
        task_number: @props.taskNumber
        required: @props.task.required
        task_init: true
        zIndex: @props.taskNumber + 1
        endpoints: []
        uuid: 0
        uuids: []
        type: @props.type
        idx: @props.idx
        plumbId: @props.plumbId
        push_update: false
      }
    else
      {
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
        idx: @props.idx
        plumbId: @props.plumbId
        push_update: false
      }

  componentDidMount: ->
    # set up some variables to use during resize events
    @me = React.findDOMNode(this)
    @width_min = parseFloat(window.getComputedStyle(@me)['min-width'])
    @width_max = parseFloat(window.getComputedStyle(@me)['max-width'])
    @bounding_rect = @me.getBoundingClientRect()
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
    jp.draggable(@props.plumbId, drag_options)
    # add an "input" endpoint
    ep = jp.addEndpoint(@props.plumbId, commonT, {uuid: @props.plumbId})
    ep.canvas.style['z-index'] = @state.task_number + 1
    eps = [ep]
    # make sure answer endpoints are drawn *after* the div is draggable and has its endpoint
    if @state.type == 'single'
      if @state.task_init
        # track uuid list manually since setState is called after the loop
        uuids = []
        uuid = 0
        for idx in [0...@state.answers.length]
          id = @getUuid(idx, uuid, uuids)
          uuids.push(id)
          uuid += 1
          ep = jp.addEndpoint(id, commonA, {uuid: id})
          ep.canvas.style['z-index'] = @state.task_number + 1
          eps.push(ep)
        @setUuid(null, uuid, uuids)
    else
      ep = jp.addEndpoint(@props.plumbId+'_name', commonA, {uuid: @props.plumbId + '_next'})
      ep.canvas.style['z-index'] = @state.task_number + 1
      eps.push(ep)
    @setState({task_init: false})
    @setState({endpoints: eps})
    return

  # Make sure workflow knows about updates
  workflowUpdate: ->
    if not @state.task_init
      @props.onUpdate(@state)

  # Keep track of unique uuids to use for each answer DOM element
  # These can't be re-used after removal, otherwise the endpoint will not draw in the right spot
  # This is a limitation of jsPlumb
  setUuid: (id, uuid, uuids) ->
    current_uuids = uuids ? @state.uuids.concat([id])
    current_uuid =  uuid ? @state.uuid + 1
    @setState({uuids: current_uuids})
    @setState({uuid: current_uuid})

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

  # when the node is removed clean up all endpoints
  componentWillUnmount: ->
    for ep in @state.endpoints
      jp.deleteEndpoint(ep)
    return

  # Callback for name change
  onName: (e) ->
    @setState({question: e.target.value}, @workflowUpdate)

  # Callback for new answer change
  onChange: (e) ->
    @setState({answer_text: e.target.value})

  # Callback for new drawing task type
  onDrawType: (e) ->
    @setState({draw_type: e.target.value})

  # Callback for new drawing task color
  onDrawColor: (e) ->
    @setState({draw_color: e.target.value})

  # check if a string is just whitespace
  isEmptyStr: (str) ->
    str.replace(/^\s+|\s+$/g, '').length == 0

  # Callback to add a new answer to the list
  handelAdd: (e) ->
    if not @isEmptyStr(@state.answer_text)
      current_answers = @state.answers.concat([@state.answer_text])
      if @state.type == 'drawing'
        current_draw_types = @state.draw_types.concat([@state.draw_type])
        current_draw_colors = @state.draw_colors.concat([@state.draw_color])
        @setState({answers: current_answers, number: current_answers.length, draw_types: current_draw_types, draw_colors: current_draw_colors}, @workflowUpdate)
      else
        @setState({answers: current_answers, number: current_answers.length, answer_text: ''}, @workflowUpdate)

  # Callback to remove an asnwer from the list
  handelRemove: (e) ->
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

  # Callback when help text is changed
  onHelp: (e) ->
    @setState({help_text: e.target.value}, @workflowUpdate)

  # Callback when answer/tool text is edited
  onEdit: (e) ->
    current_answers = @state.answers
    idx = +e.target.getAttribute('data-idx')
    current_answers[idx] = e.target.value
    @setState({answers: current_answers}, @workflowUpdate)

  # Callback when drawing task type is edited
  onEditDrawType: (e) ->
    current_draw_types = @state.draw_types
    idx = +e.target.getAttribute('data-idx')
    current_draw_types[idx] = e.target.value
    @setState({draw_types: current_draw_types}, @workflowUpdate)

  # Callback when drawing task color is edited
  onEditDrawColor: (e) ->
    current_draw_colors = @state.draw_colors
    idx = +e.target.getAttribute('data-idx')
    current_draw_colors[idx] = e.target.value
    @setState({draw_colors: current_draw_colors}, @workflowUpdate)

  # Callback when "required" box is toggled
  onReq: (e) ->
    @setState({required: e.target.checked}, @workflowUpdate)

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
        offset = jp.getOffset(ep.elementId)
        offset.left += delta
        jp.repaint(ep.elementId,offset)
        jp.dragManager.updateOffsets(@props.plumbId)
    return

  # Callback after resize to save endpoints' positions
  onResizeStop: (e) ->
    @bounding_rect = @me.getBoundingClientRect()
    for ep in @state.endpoints[1...]
      jp.revalidate(ep.elementId, null, true)
    @props.onMove()
    return

  # Useful for debugging
  onClick: (e) ->
    #console.log(@state)

  # How to draw a Question (single) task
  renderSingle: ->
    style = @props.pos
    style['zIndex'] = @state.zIndex
    if @state.zIndex > max_z
      max_z = @state.zIndex

    inputs =
      type: @state.type
      answers: @state.answers
      uuid:
        set: @setUuid
        get: @getUuid
      eps:
        add: @pushEps
        remove: @removeEps
        zIndex: @state.zIndex
        endpoints: @state.endpoints
      taskInit: @state.task_init
      remove: @handelRemove
      edit: @onEdit
      number: @state.task_number

    <div className='box question-box' style={style} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick}>
      <div className='drag-handel'>
        <span className='box-head'>
          Single
        </span>
        <a className='close close-box' onClick={@props.remove} data-wfkey={@props.wfKey}>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@props.taskNumber} plumbId={@props.plumbId} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <RequireBox setReq={@onReq} required={@state.required} />
      <AnswerList inputs={inputs} plumbId={@props.plumbId} />
      <AddAnswer boxState={@state} change={@onChange} add={@handelAdd} number={@state.task_number} />
    </div>

  # How to draw a Question (multiple) task
  renderMulti: ->
    style = @props.pos
    style['zIndex'] = @state.zIndex
    if @state.zIndex > max_z
      max_z = @state.zIndex

    inputs =
      type: @state.type
      answers: @state.answers
      uuid:
        set: @setUuid
        get: @getUuid
      taskInit: @state.task_init
      remove: @handelRemove
      edit: @onEdit
      number: @state.task_number

    <div className='box multi-box' style={style} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick}>
      <div className='drag-handel'>
        <span className='box-head'>
          Multiple
        </span>
        <a className='close close-box' onClick={@props.remove} data-wfkey={@props.wfKey}>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@props.taskNumber} plumbId={@props.plumbId} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <RequireBox setReq={@onReq} required={@state.required} />
      <AnswerList  inputs={inputs} plumbId={@props.plumbId} />
      <AddAnswer boxState={@state} change={@onChange} add={@handelAdd} number={@state.task_number} />
    </div>

  # How to draw a Drawing task
  renderDraw: ->
    style = @props.pos
    style['zIndex'] = @state.zIndex
    if @state.zIndex > max_z
      max_z = @state.zIndex

    inputs =
      type: @state.type
      answers: @state.answers
      uuid:
        set: @setUuid
        get: @getUuid
      tools: @state.draw_types
      colors: @state.draw_colors
      taskInit: @state.task_init
      remove: @handelRemove
      edit: @onEdit
      number: @state.task_number
      editDrawType: @onEditDrawType
      editDrawColor: @onEditDrawColor

    <div className='box drawing-box' style={style} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick} >
      <div className='drag-handel'>
        <span className='box-head'>
          Drawing
        </span>
        <a className='close close-box' onClick={@props.remove} data-wfkey={@props.wfKey}>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@props.taskNumber} plumbId={@props.plumbId} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <AnswerList inputs={inputs} plumbId={@props.plumbId} />
      <AddAnswer boxState={@state} change={@onChange} add={@handelAdd} number={@state.task_number} />
      <TypeColorSelect  onDrawType={@onDrawType} onDrawColor={@onDrawColor} drawType={@state.draw_type} drawColor={@state.draw_color} />
    </div>

  # Pick what task to draw
  render: ->
    switch @props.type
      when 'single' then return @renderSingle()
      when 'multiple' then return @renderMulti()
      when 'drawing' then return @renderDraw()
#

AddTaskButtons = React.createClass
  displayName: 'AddTaskButtons'

  render: ->
    <ButtonGroup>
      <Button onClick={@props.onSingle}>Question (single)</Button>
      <Button onClick={@props.onMulti}>Question (multiple)</Button>
      <Button onClick={@props.onDraw}>Drawing</Button>
    </ButtonGroup>

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
    jp.draggable(@props.type, drag_options)
    switch @props.type
      when 'start' then ep = jp.addEndpoint(@props.type, commonA, {uuid: @props.type})
      when 'end' then ep = jp.addEndpoint(@props.type, commonT, {uuid: @props.type})
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
    jp.revalidate(@ep.elementId, null, true)

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
    <div className='box-end' id={@props.type} style={style}>
      {@props.type.charAt(0).toUpperCase() + @props.type.slice(1)}
    </div>

# Handel the full workflow
Workflow = React.createClass
  displayName: 'Workflow'

  # parse the input workflow json
  getInitialState: ->
    wf = @props.wf ? {}
    pos = @props.pos ? {}
    keys = Object.keys(wf)
    if 'init' in keys
      idx = keys.indexOf('init')
      for i in [0..keys.length]
        tmp = 'T'+i
        if tmp not in keys
          init = tmp
          keys[idx] = tmp
          wf[tmp] = wf['init']
          pos[tmp] = pos['init']
          delete wf['init']
          delete pos['init']
          break
    else
      init = undefined
    key_nums = (k[1...] for k in keys)
    if key_nums.length > 0
      uuid = Math.max(key_nums...) + 1
    else
      uuid = 0
    uuids = ('task_' + k for k in key_nums)
    {
      wf: wf
      pos: pos
      keys: keys
      uuid: uuid
      uuids: uuids
      init: init
      wf_out: {}
      pos_out: {}
    }

  # Draw any existing connectors
  componentDidMount: ->
    if @state.pos['start']?
      @refs['start'].moveMe(@state.pos['start'])
    if @state.pos['end']?
      @refs['end'].moveMe(@state.pos['end'])
    if @state.init?
      idx = @state.keys.indexOf(@state.init)
      c = ['start', @state.uuids[idx]]
      jp.connect({uuids: c})
    for wfKey,w of @state.wf
      idx = @state.keys.indexOf(wfKey)
      switch w.type
        when 'single'
          for a,adx in w.answers
            if a.next?
              ndx = @state.keys.indexOf(a.next)
              c = [@state.uuids[idx] + '_answer_' + adx, @state.uuids[ndx]]
            else
              c = [@state.uuids[idx] + '_answer_' + adx, 'end']
            jp.connect({uuids: c})
        else
          if w.next?
            ndx = @state.keys.indexOf(w.next)
            c = [@state.uuids[idx] + '_next', @state.uuids[ndx]]
          else
            c = [@state.uuids[idx] + '_next', 'end']
          jp.connect({uuids: c})
    jp.bind('connection', @onConnect)
    jp.bind('connectionDetached', @onDetach)
    @getWorkflow()

  taskUpdate: (taskState) ->
    current_wf = @state.wf
    task_key = 'T' + taskState.plumbId.split('_')[1]
    current_wf[task_key].question = taskState.question
    current_wf[task_key].help = taskState.help_text
    if taskState.type != 'drawing'
      current_wf[task_key].required = taskState.required
    switch taskState.type
      when 'single'
        ans = []
        for lab, idx in taskState.answers
          a = {label: lab}
          c = jp.getConnections({source: taskState.uuids[idx]})
          if c.length > 0
            a['next'] = 'T' + c[0].targetId.split('_')[1]
          ans.push(a)
        current_wf[task_key].answers = ans
      when 'multiple'
        ans = []
        for lab in taskState.answers
          ans.push({label: lab})
        current_wf[task_key].answers = ans
      when 'drawing'
        tools = []
        for lab, idx in taskState.answers
          t =
            label: lab
            type: taskState.draw_types[idx]
            color: taskState.draw_colors[idx]
          tools.push(t)
        current_wf[task_key].tools = tools
    @setState({wf: current_wf}, @getWorkflow)

  # Get a existing/new unique uuid to use for the task node (needed for jsPlumb)
  getUuid: (idx, uuid = @state.uuid, uuids = @state.uuids) ->
    if uuids[idx]?
      return uuids[idx]
    else
      return 'task_' + uuid

  # Set a new uuid to state
  setUuid: (id) ->
    current_uuids = @state.uuids.concat([id])
    current_uuid = @state.uuid + 1
    @setState({uuids: current_uuids, uuid: current_uuid})

  # Make empty json for a task
  makeNewTask: (type, task, pos) ->
    idx = @state.keys.length
    new_key = 'T'+@state.uuid
    uuid = @getUuid(idx)
    current_wf = @state.wf
    current_pos = @state.pos
    if task?
      current_wf[new_key] = task
      current_pos[new_key] = pos
    else
      switch type
        when 'single'
          new_wf =
            question: ''
            help: ''
            required: false
            type: 'single'
            answers: []
        when 'multiple'
          new_wf =
            question: ''
            help: ''
            required: false
            type: 'multiple'
            next: undefined
            answers: []
        when 'drawing'
          new_wf =
            question: ''
            help: ''
            type: 'drawing'
            next: undefined
            tools: []
      current_wf[new_key] = new_wf
      current_pos[new_key] = {}
    @setUuid(uuid)
    current_keys = @state.keys.concat([new_key])
    @setState({wf: current_wf, pos: current_pos, keys: current_keys}, @getWorkflow)

  # Remove a task
  removeTask: (e) ->
    wfKey = e.target.getAttribute('data-wfkey')
    idx = @state.keys.indexOf(wfKey)
    current_wf = @state.wf
    delete current_wf[wfKey]
    current_pos = @state.pos
    delete current_pos[wfKey]
    current_keys = @state.keys
    current_keys.splice(idx, 1)
    current_uuids = @state.uuids
    current_uuids.splice(idx, 1)
    if wfKey == @state.init
      init = undefined
    else
      init = @state.init
    @setState({wf: current_wf, pos: current_pos, keys: current_keys, uuids: current_uuids, init: init}, @getWorkflow)

  # New task callback
  onNewSingle: (e) ->
    @makeNewTask('single')

  # New task callback
  onNewMulti: (e) ->
    @makeNewTask('multiple')

  # New task callback
  onNewDraw: (e) ->
    @makeNewTask('drawing')

  onConnect: (e) ->
    # make sure updates to tasks are updated in state.wf!!!
    sourceId = e.sourceId.split('_')
    targetId = e.targetId.split('_')
    source_key = 'T' + sourceId[1]
    target_key = 'T' + targetId[1]
    current_wf = @state.wf
    if e.sourceId == 'start'
      @setState({init: target_key}, @getWorkflow)
      return
    else if sourceId.length == 4
      adx = @refs[source_key].state.uuids.indexOf(e.sourceId)
      if e.targetId == 'end'
        delete current_wf[source_key].answers[adx]['next']
      else
        current_wf[source_key].answers[adx]['next'] = target_key
    else
      if e.targetId == 'end'
        delete current_wf[source_key]['next']
      else
        current_wf[source_key]['next'] = target_key
    @setState({wf: current_wf}, @getWorkflow)
    return

  onDetach: (e) ->
    sourceId = e.sourceId.split('_')
    source_key = 'T' + sourceId[1]
    current_wf = @state.wf
    if e.sourceId == 'start'
      @setState({init: undefined}, @getWorkflow)
      return
    if sourceId.length == 4
      # if task removed via 'x' the detach events still fire so check for existance
      if (@refs[source_key]?) and (current_wf[source_key]?)
        adx = @refs[source_key].state.uuids.indexOf(e.sourceId)
        delete current_wf[source_key].answers[adx]['next']
    else
      if (@refs[source_key]?) and (current_wf[source_key]?)
        delete current_wf[source_key]['next']
    @setState({wf: current_wf}, @getWorkflow)
    return

  # Construct workflow json from nodes
  getWorkflow: ->
    wf = {}
    pos = {}
    for k, idx in @state.keys
      p =
        top: @refs[k].me.offsetTop + 'px'
        left: @refs[k].me.offsetLeft + 'px'
        width: @refs[k].me.offsetWidth + 'px'
      if k == @state.init
        wf['init'] = @state.wf[k]
        pos['init'] = p
      else
        wf['T' + idx] = @state.wf[k]
        pos['T' + idx] = p
    pos['start'] =
      top: @refs['start'].me.offsetTop + 'px'
      left: @refs['start'].me.offsetLeft + 'px'
    pos['end'] =
      top: @refs['end'].me.offsetTop + 'px'
      left: @refs['end'].me.offsetLeft + 'px'
    # I have no idea how a drawing task gets 'answers' placed in it...
    # For now just remove it
    for tdx,t of wf
      if t.type == 'drawing'
        delete t['answers']
    @setState({wf_out: wf, pos_out: pos})

  onClear: ->
    current_wf = {}
    current_pos = {}
    current_keys = []
    current_uuids = []
    init = undefined
    @refs['start'].moveMe(null, true)
    @refs['end'].moveMe(null, true)
    @setState({wf: current_wf, pos: current_pos, keys: current_keys, uuids: current_uuids, init: init}, @getWorkflow)

  loadWf: (wf_in, pos_in) ->
    tdx = @state.uuid
    current_wf = {}
    current_pos = {}
    current_uuids = []
    current_keys = []
    key_dict = {}
    init = undefined
    for k,v of wf_in
      new_key = 'T' + tdx
      key_dict[k] = new_key
      current_keys.push(new_key)
      current_wf[new_key] = v
      current_pos[new_key] = pos_in[k]
      current_uuids.push('task_' + tdx)
      if k == 'init'
        init = new_key
      tdx += 1
    for k,v of current_wf
      if v.type == 'single'
        for a in v.answers
          if a.next?
            a.next = key_dict[a.next]
      else
        if v.next?
          v.next = key_dict[v.next]
    current_pos['start'] = pos_in['start']
    current_pos['end'] = pos_in['end']
    new_state =
      wf: current_wf
      pos: current_pos
      keys: current_keys
      uuids: current_uuids
      uuid: tdx
      init: init
    @setState(new_state, @componentDidMount)

  loadEx1: ->
    @loadWf(clone(Ex1.wf), clone(Ex1.pos))

  loadEx2: ->
    @loadWf(clone(Ex2.wf), clone(Ex2.pos))

  # Callback to make one task
  createTask: (idx, name) ->
    id = @getUuid(idx)
    <Task task={@state.wf[name]} type={@state.wf[name].type} taskNumber={idx} pos={@state.pos[name]} plumbId={id} key={id} wfKey={name} ref={name} remove={@removeTask} onUpdate={@taskUpdate} onMove={@getWorkflow} />

  render: ->
    <Row>
      <Col xs={12} style={{marginTop: 15}}>
        <div style={{fontSize: 26}}> Add Task:</div>
        <AddTaskButtons onSingle={@onNewSingle} onMulti={@onNewMulti} onDraw={@onNewDraw} />
      </Col>
      <Col xs={12} id='editor'>
        <StartEndNode type='start' ref='start' onMove={@getWorkflow} />
        <StartEndNode type='end'  ref='end' onMove={@getWorkflow} />
        {@createTask(idx, name) for name, idx in @state.keys}
      </Col>
      <Col xs={12}>
        <h3>How to use:</h3>
        <ul>
          <li>Add a new task by clicking one of the three buttons at the top of the page</li>
          <li>Move the task node by clicking and dragging the top of the task anywhere you want (page auto scrolls)</li>
          <li>The width of the task nodes can be resized by dragging the right side</li>
          <li>Enter the task's question into the top text box of the task node (this is a multi-line textarea)</li>
          <li>Enter the task's help text by clicking the "Help Text" button</li>
          <li>Add answers/tools to the task by entering them into the bottom text box (this is a multi-line textarea) and clicking the "+"</li>
          <li>Markdown preview for answer/tool is shown in the node</li>
          <li>Edit answers/tools by clicking the "pencil" icon</li>
          <li>Connect the tasks/answers with the next task by clicking and dragging the black dot to the right of the task/answer to the black dot on the left of the next task</li>
          <li>Remvoe tasks/answers/tools by clicking the "x"</li>
          <li>The Panoptes JSON for the workflow is automatically updated below (The positions of each task node on the page are also shown)</li>
          <li>Click "Load example 1" or "Load example 2" to see example workflows (make sure to click "clear" or refresh the page before loading an example)</li>
        </ul>
      </Col>
      <Col xs={3}>
        <Button onClick={@loadEx1}> Load example 1 </Button>
      </Col>
      <Col xs={3}>
        <Button onClick={@loadEx2}> Load example 2 </Button>
      </Col>
      <Col xs={3}>
        <Button onClick={@onClear}> Clear </Button>
      </Col>
      <Col xs={6}>
        <pre> {JSON.stringify(@state.wf_out, undefined, 2)} </pre>
      </Col>
      <Col xs={6}>
        <pre> {JSON.stringify(@state.pos_out, undefined, 2)} </pre>
      </Col>
    </Row>
#

# A function to clone JSON object
clone = (obj) ->
  return JSON.parse(JSON.stringify(obj))
#

#React.render(<Workflow wf={clone(Ex1.wf)} pos={clone(Ex1.pos)} />, document.getElementById('insert'))
React.render(<Workflow />, document.getElementById('insert'))
