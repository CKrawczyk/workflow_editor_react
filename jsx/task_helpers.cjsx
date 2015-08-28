React = require 'react'
Input = require 'react-bootstrap/lib/Input'
OverlayTrigger = require 'react-bootstrap/lib/OverlayTrigger'
Popover = require 'react-bootstrap/lib/Popover'
Row = require 'react-bootstrap/lib/Row'
Col = require 'react-bootstrap/lib/Col'
Button = require 'react-bootstrap/lib/Button'
MarkdownIt = require 'markdown-it'

md = MarkdownIt({breaks: true, html: true})
  .use(require 'markdown-it-emoji')
  .use(require 'markdown-it-sub')
  .use(require 'markdown-it-sup')

# Render the task name box at the top of the node
TaskName = React.createClass
  displayName: 'TaskName'

  render: ->
    task_number = 'T ' + @props.number
    style =
      'zIndex': 'inherit'
    <div className='task' id={@props.plumbId + '_name'}>
      <Input className='question' type='textarea' onChange={@props.onChange.bind(@, 'question', true)} value={@props.question} addonBefore={task_number} style={style} />
    </div>
#

# Add a button that brings up a popover where the user can add "help text" to the node
HelpButton = React.createClass
  displayName: 'HelpButton'

  closeHelp: ->
    @refs.help_popover.toggle()

  render: ->
    overlay =
      <Popover className='help-popover' title='Help text' arrowOffsetTop={121.1} arrowOffsetLeft={-11}>
        <Row>
          <Col xs={6}>
            <h4>Enter help text as <a href='https://markdown-it.github.io/' target='_blank'>markdown</a></h4>
          </Col>
          <Col xs={6}>
            <h4>Preview text as HTML</h4>
          </Col>
        </Row>
        <Row>
          <Col xs={6}>
            <Input className='help-text' type='textarea' onChange={@props.onChange.bind(@, 'help_text', true)} rows=5 value={@props.help} />
          </Col>
          <Col xs={6}>
            <div className='help-preview' dangerouslySetInnerHTML={{__html: md.render(@props.help)}}></div>
          </Col>
        </Row>
        <Button onClick={@closeHelp} block>Save</Button>
      </Popover>

    <OverlayTrigger ref='help_popover' trigger='click' placement='right' overlay={overlay}>
      <Button className='add-help' bsSize="xsmall">Help Text</Button>
    </OverlayTrigger>
#

# Add a checkbox for making a task "required"
RequireBox = React.createClass
  displayName: 'RequireBox'

  render: ->
    <span className='req'>
      <Input className='required-check'  type='checkbox' onChange={@props.onChange.bind(@, 'required', true)} checked={@props.required} label='Required' bsSize='small' />
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
      <Input className='answer-input' type='textarea' value={@props.boxState.answer_text} onChange={@props.change.bind(@, 'answer_text', false)} addonBefore={before} buttonAfter={button} style={style} />
    </div>
#

# Add dropdown list to selet color and type for drawing task
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
        <Input type='select' onChange={@props.onChange.bind(@, 'draw_type', false)} value={@props.drawType} data-idx={@props.idx}>
          <option value='point'>point</option>
          <option value='line'>line</option>
          <option value='polygon'>polygon</option>
          <option value='rectangle'>rectangle</option>
          <option value='circle'>circle</option>
          <option value='ellipse'>ellipse</option>
        </Input>
      </Col>
      <Col xs={6} className='color-select' style={s2}>
        <Input type='select' onChange={@props.onChange.bind(@, 'draw_color', false)} value={@props.drawColor} data-idx={@props.idx}>
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

module.exports =
  TaskName: TaskName
  HelpButton: HelpButton
  RequireBox: RequireBox
  AddAnswer: AddAnswer
  TypeColorSelect: TypeColorSelect
