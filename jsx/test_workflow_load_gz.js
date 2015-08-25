exports.wf = {
  "init": {
    "question": "Is the galaxy smooth or does it have a disk?",
    "help": "",
    "required": true,
    "type": "single",
    "answers": [
      {
        "label": "Smooth",
        "next": "T5"
      },
      {
        "label": "Disk",
        "next": "T1"
      },
      {
        "label": "Star"
      }
    ]
  },
  "T1": {
    "question": "Could this be edge-on?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Yes",
        "next": "T2"
      },
      {
        "label": "No",
        "next": "T6"
      }
    ]
  },
  "T2": {
    "question": "What is the shape of the bulge?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Rounded",
        "next": "T3"
      },
      {
        "label": "Boxy",
        "next": "T3"
      },
      {
        "label": "None",
        "next": "T3"
      }
    ]
  },
  "T3": {
    "question": "Anything odd?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Yes",
        "next": "T4"
      },
      {
        "label": "No"
      }
    ]
  },
  "T4": {
    "question": "What is odd?",
    "help": "",
    "type": "multiple",
    "answers": [
      {
        "label": "Ring"
      },
      {
        "label": "Lens"
      },
      {
        "label": "Disturbed"
      },
      {
        "label": "Irregular"
      },
      {
        "label": "Other"
      },
      {
        "label": "Merger"
      },
      {
        "label": "Dust lane"
      }
    ]
  },
  "T5": {
    "question": "How rounded is it?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Round",
        "next": "T3"
      },
      {
        "label": "In between",
        "next": "T3"
      },
      {
        "label": "Cigar",
        "next": "T3"
      }
    ]
  },
  "T6": {
    "question": "Is there a bar?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Yes",
        "next": "T7"
      },
      {
        "label": "No",
        "next": "T7"
      }
    ]
  },
  "T7": {
    "question": "Are there spiral arms?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Yes",
        "next": "T8"
      },
      {
        "label": "No",
        "next": "T10"
      }
    ]
  },
  "T8": {
    "question": "How tight are they?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "Tight",
        "next": "T9"
      },
      {
        "label": "Mid",
        "next": "T9"
      },
      {
        "label": "Loose",
        "next": "T9"
      }
    ]
  },
  "T9": {
    "question": "How many arms?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "1",
        "next": "T10"
      },
      {
        "label": "2",
        "next": "T10"
      },
      {
        "label": "3",
        "next": "T10"
      },
      {
        "label": "4",
        "next": "T10"
      },
      {
        "label": "5+",
        "next": "T10"
      },
      {
        "label": "Can't tell",
        "next": "T10"
      }
    ]
  },
  "T10": {
    "question": "How big is the bulge?",
    "help": "",
    "type": "single",
    "answers": [
      {
        "label": "None",
        "next": "T3"
      },
      {
        "label": "Just noticeable",
        "next": "T3"
      },
      {
        "label": "Obvious",
        "next": "T3"
      },
      {
        "label": "Dominant",
        "next": "T3"
      }
    ]
  }
};

exports.pos = {
  "init": {
    "top": "113px",
    "left": "169px",
    "width": "238px"
  },
  "T1": {
    "top": "356px",
    "left": "459px",
    "width": "208px"
  },
  "T2": {
    "top": "393px",
    "left": "1482px",
    "width": "196px"
  },
  "T3": {
    "top": "385px",
    "left": "2730px",
    "width": "196px"
  },
  "T4": {
    "top": "11px",
    "left": "3140px",
    "width": "196px"
  },
  "T5": {
    "top": "1px",
    "left": "1479px",
    "width": "196px"
  },
  "T6": {
    "top": "525px",
    "left": "737px",
    "width": "196px"
  },
  "T7": {
    "top": "826px",
    "left": "997.133px",
    "width": "196px"
  },
  "T8": {
    "top": "659px",
    "left": "1265.4px",
    "width": "196px"
  },
  "T9": {
    "top": "741px",
    "left": "1842.13px",
    "width": "215px"
  },
  "T10": {
    "top": "1045px",
    "left": "2209px",
    "width": "236px"
  },
  "start": {
    "top": "261px",
    "left": "5px"
  },
  "end": {
    "top": "677px",
    "left": "3484.63px"
  }
};
