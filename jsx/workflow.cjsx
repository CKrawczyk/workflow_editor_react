React = require 'react'
Button = require 'react-bootstrap/lib/Button'
ButtonGroup = require 'react-bootstrap/lib/ButtonGroup'
ButtonToolbar = require 'react-bootstrap/lib/ButtonToolbar'
Row = require 'react-bootstrap/lib/Row'
Col = require 'react-bootstrap/lib/Col'
Ex1 = require './test_workflow_load.js'
Ex2 = require './test_workflow_load_gz.js'
Ex3 = require './test_workflow_no_pos.js'
{Task, StartEndNode} = require './task.cjsx'

AddTaskButtons = React.createClass
  displayName: 'AddTaskButtons'

  render: ->
    <ButtonToolbar>
      <ButtonGroup>
        <Button onClick={@props.onSingle}>Question (single)</Button>
        <Button onClick={@props.onMulti}>Question (multiple)</Button>
        <Button onClick={@props.onDraw}>Drawing</Button>
      </ButtonGroup>
      <ButtonGroup>
        <Button onClick={@props.onSort}>Sort</Button>
        <Button onClick={@props.onClear}>Clear</Button>
      </ButtonGroup>
    </ButtonToolbar>
#

# Handel the full workflow
Workflow = React.createClass
  displayName: 'Workflow'

  # parse the input workflow json
  getInitialState: ->
    wf = @props.wf ? {}
    pos = {}
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
      @props.jp.connect({uuids: c})
    last_list = []
    sub_list = []
    for wfKey,w of @state.wf
      idx = @state.keys.indexOf(wfKey)
      switch w.type
        when 'single'
          for a,adx in w.answers
            if a.next?
              ndx = @state.keys.indexOf(a.next)
              c = [@refs[wfKey].state.uuids[adx], @state.uuids[ndx]]
            else
              c = [@refs[wfKey].state.uuids[adx], 'end']
            @props.jp.connect({uuids: c})
        else
          if w.next?
            ndx = @state.keys.indexOf(w.next)
            c = [@state.uuids[idx] + '_next', @state.uuids[ndx]]
          else
            c = [@state.uuids[idx] + '_next', 'end']
          @props.jp.connect({uuids: c})
          if w.type == 'drawing'
            for a,adx in w.tools
              if a.details?.length > 0
                sub_list = sub_list.concat(a.details)
                [st1, ..., st_last] = a.details
                last_list.push(st_last)
                ndx_sub = @state.uuids[@state.keys.indexOf(st1)]
                ndx_pre = @refs[wfKey].state.uuids[0]
                csub = [ndx_pre, ndx_sub]
                @props.jp.connect({uuids: csub})
    for wfKey in last_list
      idx = @state.keys.indexOf(wfKey)
      all_uuids = @refs[wfKey].state.uuids
      for ep in @refs[wfKey].state.endpoints[1...]
        @props.jp.detachAllConnections(ep.elementId)
    # set all sub-tasks as such (callbacks not hooked up yet)
    for wfKey in sub_list
      @refs[wfKey].setSubTask(true)
    @props.jp.bind('connection', @onConnect)
    @props.jp.bind('connectionDetached', @onDetach)
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
          c = @props.jp.getConnections({source: taskState.uuids[idx]})
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

  # set sub-task callback
  onSubTask: (targetId, val) ->
    targetId = targetId.split('_')
    target_key = 'T' + targetId[1]
    @refs[target_key].setSubTask(val, @onSubTask)

  # New task callback
  onNewTask: (type, e) ->
    @makeNewTask(type)

  onConnect: (e) ->
    # make sure updates to tasks are updated in state.wf!!!
    sourceId = e.sourceId.split('_')
    targetId = e.targetId.split('_')
    # jsPlumb double fires events for some reason, check for that
    if @lastConnect == e.sourceId + e.targetId
      return
    @lastConnect = e.sourceId + e.targetId
    if @lastConnect == @lastDetach
      @lastDetach = ''
    source_key = 'T' + sourceId[1]
    target_key = 'T' + targetId[1]
    current_wf = @state.wf
    if e.sourceId == 'start'
      @setState({init: target_key}, @getWorkflow)
      @refs[target_key]['previousTask'] = 'start'
      return
    if e.targetId != 'end'
      @refs[source_key]['nextTask'].push(target_key)
      if @refs[target_key]['previousTask']?
        @refs[target_key]['previousTask'].push(source_key)
      else
        @refs[target_key]['previousTask'] = [source_key]
    else
      @refs[source_key]['nextTask'].push('end')
    if @refs[source_key].state.subTask
      @refs[target_key].setSubTask(true, @onSubTask)
    switch current_wf[source_key].type
      when 'single'
        adx = @refs[source_key].state.uuids.indexOf(e.sourceId)
        if e.targetId == 'end'
          delete current_wf[source_key].answers[adx]['next']
        else
          current_wf[source_key].answers[adx]['next'] = target_key
      else
        # for drawing tasks with sub task
        if sourceId.length == 4
          @refs[target_key].setSubTask(true, @onSubTask)
          sub_task_list = [target_key]
          adx = @refs[source_key].state.uuids.indexOf(e.sourceId)
          current_wf[source_key].tools[adx]['details'] = sub_task_list
        else
          if e.targetId == 'end'
            delete current_wf[source_key]['next']
          else
            current_wf[source_key]['next'] = target_key
    @setState({wf: current_wf}, @getWorkflow)
    return

  onDetach: (e) ->
    sourceId = e.sourceId.split('_')
    targetId = e.targetId.split('_')
    # jsPlumb double fires events for some reason, check for that
    if @lastDetach == e.sourceId + e.targetId
      return
    @lastDetach = e.sourceId + e.targetId
    if @lastDetach == @lastConnect
      @lastConnect = ''
    source_key = 'T' + sourceId[1]
    target_key = 'T' + targetId[1]
    current_wf = @state.wf
    # update nextTask list
    if @refs[source_key]?
      if (e.sourceId != 'start')
        if (e.targetId != 'end')
          tdx = @refs[source_key]['nextTask'].indexOf(target_key)
          @refs[source_key]['nextTask'].splice(tdx,1)
        else
          tdx = @refs[source_key]['nextTask'].indexOf('end')
          @refs[source_key]['nextTask'].splice(tdx,1)
    # update previouseTask list
    if (e.targetId != 'end') and (@refs[target_key]?)
      if (@refs[target_key]['previousTask'] == 'start') or (@refs[target_key]['previousTask'].length? == 1)
        @refs[target_key]['previousTask'] = null
      else
        tdx = @refs[target_key]['previousTask'].indexOf(source_key)
        @refs[target_key]['previousTask'].splice(tdx, 1)
      isSubTask = false
      for pt in @refs[target_key]['previousTask']
        isSubTask = isSubTask or @refs[pt]?.state.subTask
      @refs[target_key].setSubTask(isSubTask, @onSubTask)
    if e.sourceId == 'start'
      @setState({init: undefined}, @getWorkflow)
      return
    if current_wf[source_key]?
      switch current_wf[source_key].type
        when 'single'
          # if task removed via 'x' the detach events still fire so check for existance
          if (@refs[source_key]?)
            adx = @refs[source_key].state.uuids.indexOf(e.sourceId)
            delete current_wf[source_key].answers[adx]['next']
        else
          if (@refs[source_key]?)
            if sourceId.length == 4
              adx =  @refs[source_key].state.uuids.indexOf(e.sourceId)
              delete current_wf[source_key].tools[adx]['details']
            else
              delete current_wf[source_key]['next']
      @setState({wf: current_wf}, @getWorkflow)
    return

  doSort: (task_map, t, D) ->
    for i in task_map[t]
      msg = i + ' ' + D[i] + ' ,' + D[t]
      if (i not of D) or (D[i] <= D[t])
        D[i] = D[t] + 1
      @doSort(task_map, i, D)

  # function to auto-position nodes
  onSort: ->
    if @state.init
      task_map ={end: []}
      for k in @state.keys
        task_map[k] = remove_dup(@refs[k].nextTask)
        if task_map[k].length == 0
          # make sure end node is sorted to the far right
          task_map[k] = ['end']
      start = @state.init
      D = {}
      D[@state.init] = 0
      @doSort(task_map, start, D)
      levels = {}
      for k,v of D
        if levels[v]?
          levels[v].push(k)
        else
          levels[v] = [k]
      posX = 150
      for i in [0...Object.keys(levels).length]
        max_width = 0
        posY = 20
        for t in levels[i]
          # move the task div
          @refs[t].moveMe({left: posX, top: posY})
          # calculate new y position
          posY += @refs[t].me.offsetHeight + 20
          # calculate next x position
          w = @refs[t].me.offsetWidth
          if w > max_width
            max_width = w
        posX += 50 + max_width
      @getWorkflow()
    else
      console.log('start node must be hooked up to use sort')
      return

  # Construct workflow json from nodes
  getWorkflow: ->
    task_copy = (task, key_map, task_ref, sub_tasks_parent, k) =>
      p =
        top: task_ref.me.offsetTop + 'px'
        left: task_ref.me.offsetLeft + 'px'
        width: task_ref.me.offsetWidth + 'px'
      switch task.type
        when 'single'
          answers_out = []
          for a in task.answers
            ans = {label: a.label}
            if a.next and not task_ref.state.subTask
              ans['next'] = key_map[a.next]
            answers_out.push(ans)
          output = {
            'question': task.question
            'help': task.help
            'type': task.type
            'answers': answers_out
            'pos': p
          }
          if not task_ref.state.subTask
            output['required'] = task.required
          output
        when 'multiple'
          output = {
            'question': task.question
            'help': task.help
            'type': task.type
            'answers': task.answers
            'pos': p
          }
          if not task_ref.state.subTask
            output['next'] = key_map[task.next]
            output['required'] = task.required
          output
        when 'drawing'
          tools_out = []
          for t in task.tools
            tool = {
              label: t.label
              type: t.type
              color: t.color
            }
            if t.details?
              sub_tasks_parent.push(key_map[k])
              target_key = t.details[0]
              sub_task_list = [key_map[target_key]]
              while target_key != 'end'
                switch @state.wf[target_key].type
                  when 'single'
                    target_key = @state.wf[target_key].answers[0].next
                  when 'multiple'
                    target_key = @state.wf[target_key].next
                if target_key?
                  sub_task_list.push(key_map[target_key])
                else
                  target_key = 'end'
              tool['details'] = sub_task_list
            tools_out.push(tool)
          {
            'instruction': task.question ? task.instruction
            'help': task.help
            'type': task.type
            'next': key_map[task.next]
            'tools': tools_out
            'pos': p
          }
    wf = {}
    pos = {}
    key_map = {}
    sub_tasks_parent = []
    for k, idx in @state.keys
      key_map[k] = 'T' + idx
    for k, idx in @state.keys
      if k == @state.init
        wf['init'] = task_copy(@state.wf[k], key_map, @refs[k], sub_tasks_parent, k)
      else
        wf['T' + idx] = task_copy(@state.wf[k], key_map, @refs[k], sub_tasks_parent, k)
    # replace references to sub-tasks with the approprate JSON
    for stp in sub_tasks_parent
      if stp == @state.init
        stp = 'init'
      for t in wf[stp].tools
        if t.details
          det = []
          for st in t.details
            # make sure I don't double remove an object from wf
            if typeof(st) is 'string'
              det.push(wf[st])
              delete wf[st]
            else
              det.push(st)
          t.details = det
    pos['start'] =
      top: @refs['start'].me.offsetTop + 'px'
      left: @refs['start'].me.offsetLeft + 'px'
    pos['end'] =
      top: @refs['end'].me.offsetTop + 'px'
      left: @refs['end'].me.offsetLeft + 'px'
    # I have no idea how a drawing task gets 'answers' placed in it...
    # For now just remove it
    @setState({wf_out: wf, pos_out: pos}, @props.onWfChange)

  onClear: ->
    current_wf = {}
    current_pos = {}
    current_keys = []
    current_uuids = []
    init = undefined
    @refs['start'].moveMe(null, true)
    @refs['end'].moveMe(null, true)
    @setState({wf: current_wf, pos: current_pos, keys: current_keys, uuids: current_uuids, init: init}, @getWorkflow)

  loadWf: (wf_in) ->
    tdx = @state.uuid
    current_wf = {}
    current_pos = {}
    current_uuids = []
    current_keys = []
    key_dict = {}
    init = undefined
    ct = 0
    for k,v of wf_in
      new_key = 'T' + tdx
      key_dict[k] = new_key
      current_keys.push(new_key)
      current_wf[new_key] = v
      if v.type == 'drawing'
        current_wf[new_key]['question'] = current_wf[new_key]['instruction']
      top = if ct%2==0 then '0px' else '300px'
      current_pos[new_key] = wf_in[k].pos ? {top: top, left: 150 + ct * 250 + 'px', width: '200px'}
      ct += 1
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
        if v.type == 'drawing'
          for a in v.tools
            # extract subtask json list as tasks
            if a.details?
              sub_task_list = []
              for st, sdx in a.details
                new_key = 'T' + tdx
                # make sure nothing is overwritten
                k_key = new_key
                kdx = tdx
                while k_key in key_dict
                  kdx += 1
                  k_key = 'T' + kdx
                key_dict[k_key] = new_key
                current_keys.push(new_key)
                sub_task_list.push(new_key)
                current_uuids.push('task_' + tdx)
                st['required'] = false
                current_wf[new_key] = st
                top = if ct%2==0 then '0px' else '300px'
                current_pos[new_key] = st.pos ? {top: top, left: 150 + ct * 250 + 'px', width: '200px'}
                ct += 1
                tdx +=1
                if a.details[sdx+1]?
                  if st.type == 'single'
                    st['answers'][0]['next'] = 'T' + tdx
                  else
                    st['next'] = 'T' + tdx
              a.details = sub_task_list
    p_max = 0
    for k,v of current_pos
      p_task = parseInt(v.left) + parseInt(v.width)
      p_max = p_task if p_task > p_max
    current_pos['end'] =
      left: p_max + 100 + 'px'
      top: '50%'
    new_state =
      wf: current_wf
      pos: current_pos
      keys: current_keys
      uuids: current_uuids
      uuid: tdx
      init: init
    @setState(new_state, @componentDidMount)

  loadEx1: ->
    @loadWf(clone(Ex1.wf))

  loadEx2: ->
    @loadWf(clone(Ex2.wf))

  loadEx3: ->
    @loadWf(clone(Ex3.wf))

  # Callback to make one task
  createTask: (idx, name) ->
    id = @getUuid(idx)
    <Task jp={@props.jp} task={@state.wf[name]} type={@state.wf[name].type} taskNumber={idx} pos={@state.pos[name]} plumbId={id} key={id} wfKey={name} ref={name} remove={@removeTask} onUpdate={@taskUpdate} onMove={@getWorkflow} />

  render: ->
    <Row>
      <Col xs={12} style={{marginTop: 15}}>
        <div style={{fontSize: 26}}> Add Task:</div>
        <AddTaskButtons onSingle={@onNewTask.bind(@, 'single')} onMulti={@onNewTask.bind(@, 'multiple')} onDraw={@onNewTask.bind(@, 'drawing')} onSort={@onSort} onClear={@onClear} />
      </Col>
      <Col xs={12} id='editor' className='editor noselect'>
        <StartEndNode jp={@props.jp} type='start' ref='start' onMove={@getWorkflow} />
        <StartEndNode jp={@props.jp} type='end'  ref='end' onMove={@getWorkflow} />
        {@createTask(idx, name) for name, idx in @state.keys}
      </Col>
    </Row>
#

# A function to clone JSON object
clone = (obj) ->
  return JSON.parse(JSON.stringify(obj))

# A function to remove duplicates in an array
remove_dup = (ar) ->
  if ar.length == 0
    return []
  res = {}
  res[ar[key]] = ar[key] for key in [0..ar.length-1]
  value for key, value of res

module.exports = Workflow
