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
    "top": "215px",
    "left": "165px",
    "width": "196px"
  },
  "T1": {
    "top": "93px",
    "left": "443px",
    "width": "196px"
  },
  "T2": {
    "top": "381px",
    "left": "443px",
    "width": "196px"
  },
  "T3": {
    "top": "109px",
    "left": "795px",
    "width": "248px"
  },
  "T4": {
    "top": "400px",
    "left": "795px",
    "width": "248px"
  },
  "start": {
    "top": "338px",
    "left": "11px"
  },
  "end": {
    "top": "288px",
    "left": "1295px"
  }
}
