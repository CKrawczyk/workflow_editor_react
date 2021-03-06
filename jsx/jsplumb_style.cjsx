# define the styles for various jsPlumb elements
connectorHoverStyle =
  lineWidth: 3
  strokeStyle: "#888"
  outlineWidth: 1.5
  outlineColor: "white"

endpointHoverStyle =
  fillStyle: "#888"

connectorPaintStyle =
  lineWidth: 3
  strokeStyle: "#000"
  joinstyle: "round"
  outlineColor: "white"
  outlineWidth: 1.5
  dashstyle: "1 0"

connectorPaintStyleDashed =
  lineWidth: 3
  strokeStyle: "#000"
  joinstyle: "round"
  outlineColor: "white"
  outlineWidth: 1.5
  dashstyle: "4 2"

commonA =
  connector: ["Flowchart",
    stub: 30
    cornerRadius: 5
    alwaysRespectStubs: false
    midpoint: 0.5]
  #connector: ["Straight"]
  #connectior: ["Bezier", { curviness: 150 }]
  #connectior: ["State Machine"]
  anchor: "Right"
  isSource: true
  endpoint: "Dot"
  connectorStyle: connectorPaintStyle
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  scope: 'normal'
  paintStyle:
    fillStyle: "#000"
    radius: 5

commonA_open =
  connector: ["Flowchart",
    stub: 30
    cornerRadius: 5
    alwaysRespectStubs: false
    midpoint: 0.5]
  #connector: ["Straight"]
  #connectior: ["Bezier", { curviness: 150 }]
  #connectior: ["State Machine"]
  anchor: "Right"
  isSource: true
  endpoint: "Dot"
  connectorStyle: connectorPaintStyleDashed
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  scope: 'sub'
  paintStyle:
    fillStyle: "transparent"
    strokeStyle: "#000"
    radius: 4
    lineWidth: 2

commonT =
  anchor: "Left"
  isTarget: true
  endpoint: "Dot"
  maxConnections: -1
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  scope: 'normal sub'
  dropOptions:
    hoverClass: "hover"
    activeClass: "active"
  paintStyle:
    fillStyle: "#000"
    radius: 7

commonT_draw =
  anchor: "Left"
  isTarget: true
  endpoint: "Dot"
  maxConnections: -1
  hoverPaintStyle: endpointHoverStyle
  connectorHoverStyle: connectorHoverStyle
  scope: 'normal'
  dropOptions:
    hoverClass: "hover"
    activeClass: "active"
  paintStyle:
    fillStyle: "#000"
    radius: 7

module.exports = {
  commonA
  commonA_open
  commonT
  commonT_draw
}
