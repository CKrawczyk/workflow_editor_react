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
    'next': 'T5',
    'type': 'drawing',
    'tools': [
      {
        'label': 'CAT!',
        'type': 'point',
        'color': 'red',
        'details': [
          {
            'question': 'sub_task_2',
            'help': '',
            'type': 'single',
            'answers': [
              {
                'label': 'fun'
              },
              {
                'label': 'not fun'
              }
            ]
          }
        ]
      }
    ]
  },
  'T4': {
    'instruction': 'Click the bacon',
    'help': '',
    'next': 'T5',
    'type': 'drawing',
    'tools': [
      {
        'label': 'BACON!',
        'type': 'point',
        'color': 'red',
        'details': [
          {
            'question': 'sub_task_1',
            'help': '',
            'type': 'multiple',
            'answers': [
              {
                'label': 'fun'
              },
              {
                'label': 'not fun'
              }
            ]
          },
          {
            'question': 'sub_task_3',
            'help': '',
            'type': 'multiple',
            'answers': [
              {
                'label': 'crap'
              },
              {
                'label': 'bubbles'
              }
            ]
          }
        ]
      }
    ]
  },
  'T5': {
    'question': 'Are you done yet?',
    'help': '',
    'type': 'multiple',
    'answers': [
      {
        'label': 'yes'
      },
      {
        'label': 'no'
      }
    ]
  }
}
