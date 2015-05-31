exports.wf = {
  "init": {
    "question": "Is it a cat or bacon?",
    "help": "",
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
  },
  "T1": {
    "question": "Is it cute?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "yes",
        "next": "T3"
      },
      {
        "label": "no",
        "next": "T3"
      }
    ]
  },
  "T2": {
    "question": "Will you eat it?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "yes",
        "next": "T4"
      },
      {
        "label": "no",
        "next": "T4"
      }
    ]
  },
  "T3": {
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
  },
  "T4": {
    "question": "Click the bacon",
    "help": "",
    "type": "drawing",
    "tools": [
      {
        "label": "BACON!",
        "type": "point",
        "color": "green"
      }
    ]
  }
}

exports.pos = {
  "init": {
    "top": 221.00001525878906,
    "left": 275.00001525878906,
    "width": 196
  },
  "T1": {
    "top": 86,
    "left": 669.6499786376953,
    "width": 196
  },
  "T2": {
    "top": 386.00001525878906,
    "left": 663.6499786376953,
    "width": 196
  },
  "T3": {
    "top": 104,
    "left": 1146.8833770751953,
    "width": 248
  },
  "T4": {
    "top": 405.00001525878906,
    "left": 1145.8833770751953,
    "width": 248
  },
  "start": {
    "top": 338.00001525878906,
    "left": 11
  },
  "end": {
    "top": 327.00001525878906,
    "left": 1694.3999786376953
  }
}
