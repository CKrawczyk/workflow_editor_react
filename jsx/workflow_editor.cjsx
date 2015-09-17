React = require 'react'
Row = require 'react-bootstrap/lib/Row'
Col = require 'react-bootstrap/lib/Col'
Button = require 'react-bootstrap/lib/Button'
Workflow = require './workflow.cjsx'

Page = React.createClass
  dispalyName: 'Page'

  getInitialState: ->
    {wf: {}}

  onUpdate: ->
    @setState({wf: @refs['editor'].state.wf_out})

  loadEx1: ->
    @refs['editor'].loadEx1()

  loadEx2: ->
    @refs['editor'].loadEx2()

  loadEx3: ->
    @refs['editor'].loadEx3()

  render: ->
    <div>
      <Workflow ref="editor" jp={@props.jp} onWfChange={@onUpdate} />
      <Row>
        <Col xs={12}>
          <h3>How to use:</h3>
          <ul>
            <li>Add a new task by clicking one of the three buttons at the top of the page</li>
            <li>Move the task node by clicking and dragging the top of the task anywhere you want (page auto scrolls)</li>
            <li>The width of the task nodes can be resized by dragging the right side</li>
            <li>Enter the task's question into the top text box of the task node (this is a multi-line textarea)</li>
            <li>Enter the task's help text (and see markdown preview) by clicking the "Help Text" button</li>
            <li>Add answers/tools to the task by entering them into the bottom text box (this is a multi-line textarea) and clicking the "+"</li>
            <li>Markdown preview for answer/tool is shown in the node</li>
            <li>Edit answers/tools by clicking the "pencil" icon</li>
            <li>Connect the tasks/answers with the next task by clicking and dragging the black dot to the right of the task/answer to the black dot on the left of the next task</li>
            <li>Remvoe tasks/answers/tools by clicking the "x"</li>
            <li>The Panoptes JSON for the workflow is automatically updated below (The positions of each task node on the page are also shown)</li>
            <li>Click "Load example 1", "Load example 2", or "Load example 3" to see example workflows (make sure to click "clear" or refresh the page before loading an example)</li>
            <li>Click "sort" or automatically place the nodes based on the current connections (start node must be hooked up for this to work)</li>
          </ul>
        </Col>
        <Col xs={2}>
          <Button onClick={@loadEx1}> Load example 1 </Button>
        </Col>
        <Col xs={2}>
          <Button onClick={@loadEx2}> Load example 2 </Button>
        </Col>
        <Col xs={2}>
          <Button onClick={@loadEx3}> Load example 3 </Button>
        </Col>
        <Col xs={8}>
          <pre> {JSON.stringify(@state.wf, undefined, 2)} </pre>
        </Col>
      </Row>
    </div>

# need to make a new jsPlumb instance to work with
jp =  jsPlumb.getInstance()

React.render(<Page jp={jp} />, document.getElementById('insert'))
