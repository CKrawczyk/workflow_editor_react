exports.wf = {
  'init': {
    'question': 'Is it a cat or bacon?',
    'help': 'Some help text\nWritten in _markdown_ :D',
    'required': true,
    'type': 'single',
    'answers': [
      {
        'label': 'cat',
        'next': 'T1'
      },
      {
        'label': 'bacon',
        'next': 'T2'
      }
    ]
  },
  'T1': {
    'question': 'Is it cute?',
    'help': '',
    'type': 'single',
    'answers': [
      {
        'label': 'yes',
        'next': 'T3'
      },
      {
        'label': 'no',
        'next': 'T3'
      }
    ]
  },
  'T2': {
    'question': 'Will you eat it?',
    'help': '',
    'type': 'single',
    'answers': [
      {
        'label': 'yes',
        'next': 'T4'
      },
      {
        'label': 'no',
        'next': 'T4'
      }
    ]
  },
  'T3': {
    'instruction': 'Click the cat',
    'help': '',
    'type': 'drawing',
    'tools': [
      {
        'label': 'CAT!',
        'type': 'point',
        'color': 'red',
        'details': ['T6', 'T7']
      }
    ]
  },
  'T4': {
    'instruction': 'Click the bacon',
    'help': '',
    'type': 'drawing',
    'tools': [
      {
        'label': 'BACON!',
        'type': 'point',
        'color': 'green',
        'details': ['T5', 'T7']
      }
    ]
  },
  'T5': {
    'question': 'sub_task_1',
    'help': '',
    'type': 'multiple',
    'next': 'T7',
    'required': false,
    'answers': [
      {
        'label': 'fun'
      },
      {
        'label': 'not fun'
      }
    ]
  },
  'T6': {
    'question': 'sub_task_2',
    'help': '',
    'type': 'single',
    'required': false,
    'answers': [
      {
        'label': 'fun',
        'next': 'T7'
      },
      {
        'label': 'not fun',
        'next': 'T7'
      }
    ]
  },
  'T7': {
    'question': 'sub_task_3',
    'help': '',
    'type': 'multiple',
    'required': false,
    'answers': [
      {
        'label': 'crap'
      },
      {
        'label': 'bubbles'
      }
    ]
  }
}

exports.pos = {
  'init': {
    'top': '215px',
    'left': '165px',
    'width': '196px'
  },
  'T1': {
    'top': '93px',
    'left': '443px',
    'width': '196px'
  },
  'T2': {
    'top': '381px',
    'left': '443px',
    'width': '196px'
  },
  'T3': {
    'top': '11px',
    'left': '737px',
    'width': '248px'
  },
  'T4': {
    'top': '400px',
    'left': '736px',
    'width': '248px'
  },
  'T5': {
    'top': '604px',
    'left': '1085px',
    'width': '200px'
  },
  'T6': {
    'top': '146px',
    'left': '1083px',
    'width': '200px'
  },
  'T7': {
    'top': '570px',
    'left': '1462px',
    'width': '200px'
  },
  'start': {
    'top': '338px',
    'left': '11px'
  },
  'end': {
    'top': '384px',
    'left': '1885px'
  }
}
