# redraw function for panning and zooming
redraw = () ->
    vis.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
    return

# drag event handler for fixing nodes
dragstart = (d) ->
    d3.select(this).classed("fixed", d.fixed = true)
    d3.event.sourceEvent.stopPropagation()
    return

# right click event handler for unfixing nodes
rightclick = (d) ->
    d3.select(this).classed("fixed", d.fixed = false)
    d3.event.preventDefault()
    return

width = 1000
height = 400

min = d3.min(dataset.nodes, (d) -> d.score)
max = d3.max(dataset.nodes, (d) -> d.score)

color = (value) ->
    if (value == null) 
        return "#ccc"
    return red_green_scale(value)

red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min,max)))
            .range(["green","yellow","red"])


edges = []
dataset.edges.forEach (e) ->

  # Get the source and target nodes
  sourceNode = dataset.nodes.filter((n) ->
    n.id is e.source
  )[0]
  targetNode = dataset.nodes.filter((n) ->
    n.id is e.target
  )[0]

  # Add the edge to the array
  edges.push
    source: sourceNode
    target: targetNode

  return

svg = d3.select("#chart-network")
        .append("svg")
        .attr("width", $("#chart-network").width())
        .attr("height", height)
        .attr("preserveAspectRatio", "xMidYMid meet")
        .attr("pointer-events", "all")
        .call(d3.behavior.zoom().on("zoom", redraw));

# resize svg when window resizes
window.onresize = () ->
    svg.attr("width", $("#chart-network").width())

# add group for visible area to enable zooming
vis = svg.append('svg:g')

force = d3.layout.force()
          .nodes(dataset.nodes)
          .links(edges)
          .size([width,height])
          .start()

drag = force.drag().on("dragstart", dragstart)

edges = vis.selectAll("line")
           .data(edges)
           .enter()
           .append("line")
           .style("stroke", "#ccc")
           .style("stroke-width", 1)

nodes = vis.selectAll("circle")
           .data(dataset.nodes)
           .enter()
           .append("circle")
           .attr("r", (d) -> d.size)
           .style("fill", (d,i) -> color(d.score))
           .on("contextmenu", rightclick)
           .call(force.drag)

nodes.append("title")
     .text((d) -> d.name + " " + d.score)

force.on("tick", ->
    edges.attr("x1", (d) -> d.source.x)
         .attr("y1", (d) -> d.source.y)
         .attr("x2", (d) -> d.target.x)
         .attr("y2", (d) -> d.target.y)

    nodes.attr("cx", (d) -> d.x)
         .attr("cy", (d) -> d.y)
    )
