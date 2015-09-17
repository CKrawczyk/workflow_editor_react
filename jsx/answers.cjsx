React = require 'react'
Input = require 'react-bootstrap/lib/Input'
Button = require 'react-bootstrap/lib/Button'
OverlayTrigger = require 'react-bootstrap/lib/OverlayTrigger'
Popover = require 'react-bootstrap/lib/Popover'
Sty = require './jsplumb_style.cjsx'
Helpers = require './task_helpers.cjsx'
TypeColorSelect = Helpers.TypeColorSelect
{Markdown, MarkdownEditor} = require 'markdownz'

# Styling for the answers within the list
AnswerItem = React.createClass
  displayName: 'AnswerItem'

  componentDidMount: ->
    # only add endpoints *after* the parent div is draggable (order matters here)!
    if (not @props.inputs.task_init) and (@props.inputs.type != 'multiple')
      switch @props.inputs.type
        when 'single' then ep = @props.jp.addEndpoint(@props.inputs.listId, Sty.commonA, {uuid: @props.inputs.listId})
        when 'drawing' then ep = @props.jp.addEndpoint(@props.inputs.listId, Sty.commonA_open, {uuid: @props.inputs.listId})
      @props.inputs.setUuid(@props.inputs.listId)
      ep.canvas.style['z-index'] = @props.eps.zIndex
      @props.eps.add(ep)
      @props.jp.revalidate(ep.elementId, null, true)
      @props.jp.dragManager.updateOffsets(@props.inputs.plumbId)
    return

  componentWillUnmount: ->
    # properly remove the endpoint and detach all connectors for the task
    # always remove the final endpoint in the list since the remaining items will all move up
    # the multiple task does not have endpoins for each answer
    if (@props.inputs.type != 'multiple')
      [..., ep] = @props.eps.endpoints
      @props.jp.deleteEndpoint(ep)
      @props.jp.dragManager.endpointDeleted(ep)
      for ep in @props.eps.endpoints[1...]
        @props.jp.detachAllConnections(ep.elementId)
      @props.eps.remove()
    return

  # check if a string is just whitespace
  isEmptyStr: (str) ->
    str.replace(/^\s+|\s+$/g, '').length == 0

  render: ->
    closeMe = =>
      @refs[@props.inputs.refMe].toggle()

    # format the popup overlay
    if @props.inputs.type == 'drawing'
      overlay =
        <Popover className='edit-popover' title='Edit Answer' arrowOffsetTop={142} arrowOffsetLeft={-11}>
          <MarkdownEditor className='help-text' rows={5} cols={70} value={@props.inputs.answer} onChange={@props.inputs.edit.bind(@, 'answers', @props.inputs.idx)} />
          <TypeColorSelect nopad=true edit={true} onChange={@props.inputs.edit} drawType={@props.inputs.tool} drawColor={@props.inputs.color} idx={@props.inputs.idx} />
          <Button onClick={closeMe} block>Save</Button>
        </Popover>
    else
      overlay =
        <Popover className='edit-popover' title='Edit Answer' arrowOffsetTop={121} arrowOffsetLeft={-11}>
          <MarkdownEditor className='help-text' rows={5} cols={70} value={@props.inputs.answer} onChange={@props.inputs.edit.bind(@, 'answers', @props.inputs.idx)} />
          <Button onClick={closeMe} block>Save</Button>
        </Popover>

    # format label
    if @props.inputs.type == 'drawing'
      lab = 'T '
      tools = @props.inputs.tool + ', ' + @props.inputs.color
    else
      lab = 'A '
      tools = ''

    <li className='answer-item' id={@props.inputs.listId}>
      {lab + @props.inputs.idx + ': ' + tools}
      <a className='close noselect' onClick={@props.inputs.remove} data-idx={@props.inputs.idx}>&times;</a>
      <OverlayTrigger ref={@props.inputs.refMe} trigger='click' placement='right' overlay={overlay}>
        <i className='fa fa-pencil edit-icon'></i>
      </OverlayTrigger>
      <Markdown className='lab'>{if @isEmptyStr(@props.inputs.text) then '&nbsp;' else @props.inputs.text}</Markdown>
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
        @props.jp.revalidate(ep.elementId, null, true)
      # tell jsPlumb's dragManager to update the offsets
      @props.jp.dragManager.updateOffsets(@props.plumbId)
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
      #inputs.editDrawType = @props.inputs.editDrawType
      #inputs.editDrawColor = @props.inputs.editDrawColor

    <AnswerItem jp={@props.jp} key={'AI_' + idx} inputs={inputs} eps={@props.inputs.eps} />

  render: ->
    N = @props.inputs.answers.length
    ul_id = @props.plumbId + '_answers'
    <ul className='list-unstyled' id={ul_id}>
      {@createAnswer(idx, text, N, @props.inputs.uuid.get) for text, idx in @props.inputs.answers}
    </ul>
#

module.exports = AnswerList
