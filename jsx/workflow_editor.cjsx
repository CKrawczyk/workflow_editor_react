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
    <div className='task' id={'task_' + @props.number + '_name'}>
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
      jp.dragManager.updateOffsets('task_' + @props.number)
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
      for ep in @props.eps.endpoints[1...]
        # recaculate the node position based on the DOM element
        jp.revalidate(ep.elementId, null, true)
      # tell jsPlumb's dragManager to update the offsets
      jp.dragManager.updateOffsets('task_' + @props.inputs.number)

  createAnswer: (idx, text, N, getUuid) ->
    inputs =
      N: N
      idx: idx
      listId: getUuid(idx)
      ul_id: 'task_' + @props.inputs.number + '_answers'
      remove: @remove
      refMe: 'edit_answer_'+idx
      text: text
      answer: @props.inputs.answers[idx]
      edit: @props.inputs.edit
      task_init: @props.inputs.taskInit
      setUuid: @props.inputs.uuid.set
      type: @props.inputs.type
    if @props.inputs.type == 'drawing'
      inputs.tool = @props.inputs.tools[idx]
      inputs.color = @props.inputs.colors[idx]
      inputs.editDrawType = @props.inputs.editDrawType
      inputs.editDrawColor = @props.inputs.editDrawColor

    <AnswerItem key={'AI_' + idx} inputs={inputs} number={@props.inputs.number} eps={@props.inputs.eps} />

  render: ->
    N = @props.inputs.answers.length
    ul_id = 'task_' + @props.inputs.number + '_answers'
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

# Global value that will be moved later on
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
    if @props.type == 'single'
      next = (a.next for a in @props.task.answers)
    else
      next = @props.task.next
    if @props.task
      {
        answers: answers
        draw_types: draw_types
        draw_colors: draw_colors
        next: next
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
      }
    else
      if @props.type == 'single'
        next = []
      else
        next = undefined
      {
        answers: []
        draw_types: []
        draw_colors: []
        next: next
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
      return 'task_' + @state.task_number + '_answer_' + idx
    # if it is already in the list, use existing value
    if uuids[idx]?
      return @state.uuids[idx]
    # if not make a new unique one
    else
      return 'task_' + @state.task_number + '_answer_' + uuid

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
  # this may need more later on when I test it
  componentWillUnmount: ->
    jp.removeAllEndpoints(@props.plumbId)
    return

  # Callback for name change
  onName: (e) ->
    @setState({question: e.target.value})

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
      @setState({answers: current_answers})
      @setState({number: current_answers.length})
      @setState({answer_text: ''})
      if @state.type == 'drawing'
        current_draw_types = @state.draw_types.concat([@state.draw_type])
        current_draw_colors = @state.draw_colors.concat([@state.draw_color])
        @setState({draw_types: current_draw_types})
        @setState({draw_colors: current_draw_colors})

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
      @setState({draw_types: current_draw_types})
      @setState({draw_colors: current_draw_colors})
    @setState({answers: current_answers})
    @setState({number: current_answers.length})

  # Callback when help text is changed
  onHelp: (e) ->
    @setState({help_text: e.target.value})

  # Callback when answer/tool text is edited
  onEdit: (e) ->
    current_answers = @state.answers
    idx = +e.target.getAttribute('data-idx')
    current_answers[idx] = e.target.value
    @setState({answers: current_answers})

  # Callback when drawing task type is edited
  onEditDrawType: (e) ->
    current_draw_types = @state.draw_types
    idx = +e.target.getAttribute('data-idx')
    current_draw_types[idx] = e.target.value
    @setState({draw_types: current_draw_types})

  # Callback when drawing task color is edited
  onEditDrawColor: (e) ->
    current_draw_colors = @state.draw_colors
    idx = +e.target.getAttribute('data-idx')
    current_draw_colors[idx] = e.target.value
    @setState({draw_colors: current_draw_colors})

  # Callback when "required" box is toggled
  onReq: (e) ->
    @setState({required: e.target.checked})

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
    #jp.dragManager.updateOffsets(@props.plumbId)
    return

  # Useful for debugging
  onClick: (e) ->
    console.log(@state)

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

    <div className='box question-box' style={style} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick} >
      <div className='drag-handel'>
        <span className='box-head'>
          Single
        </span>
        <a className='close close-box'>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@state.task_number} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <RequireBox setReq={@onReq} required={@state.required} />
      <AnswerList inputs={inputs} />
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

    <div className='box multi-box' style={style} id={@props.plumbId} ref={@props.plumbId} onClick={@onClick} >
      <div className='drag-handel'>
        <span className='box-head'>
          Multiple
        </span>
        <a className='close close-box'>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@state.task_number} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <RequireBox setReq={@onReq} required={@state.required} />
      <AnswerList  inputs={inputs} />
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
        <a className='close close-box'>&times;</a>
        <br />
      </div>
      <TaskName nameMe={@onName} question={@state.question} number={@state.task_number} />
      <HelpButton help={@state.help_text} setHelp={@onHelp} />
      <AnswerList inputs={inputs} />
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

# Some example input for testing
example_task = {
  "question": "Is it a cat or bacon?",
  "help": "Some example help text!",
  "required": true,
  "type": "single",
  "answers": [
    {
      "label": "cat",
      "next": "T1"
    },
    {
      "label": "bacon",
      "next": "T2"
    }
  ]
}

p1 = {
  "top": 221,
  "left": 275,
  "width": 200
}

example_task_2 = {
  "question": "Is it cute?",
  "help": "",
  "type": "multiple",
  "next": "T3"
  "answers": [
    {
      "label": "yes",
    },
    {
      "label": "no",
    }
  ]
}

p2 = {
  "top": 86,
  "left": 669.65,
  "width": 200
}

example_task_3 = {
  "question": "Click the cat",
  "help": "",
  "type": "drawing",
  "tools": [
    {
      "label": "CAT!",
      "type": "point",
      "color": "red"
    }
  ]
}

p3 = {
  "top": 104,
  "left": 1050,
  "width": 246
}

React.render(
  <div>
    <Task task={example_task} type={example_task.type} taskNumber={0} pos={p1} plumbId='task_0' />
    <Task task={example_task_2} type={example_task_2.type} taskNumber={1} pos={p2} plumbId='task_1' />
    <Task task={example_task_3} type={example_task_3.type} taskNumber={2} pos={p3} plumbId='task_2' />
  </div>,
  document.getElementById('editor'))
