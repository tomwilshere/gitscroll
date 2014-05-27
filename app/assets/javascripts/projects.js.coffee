return if window.commits == undefined || d3Network == null

$('#options').affix({
  offset: {
    top: () ->
      101 + $('.project-info').height()
    # bottom: () ->
    #   this.bottom = $('.footer').outerHeight(true)
  }
})

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

dataset = d3Network

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

width = $("#chart-network").width()
height = $("#chart-network").height()

svg = d3.select("#chart-network")
        .append("svg")
        .attr("width", width)
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

window.nodes = vis.selectAll("circle")
           .data(dataset.nodes)
           .enter()
           .append("circle")
           .attr("r", (d) -> d.size)
           .style("fill", (d) -> color(d))
           .on("contextmenu", rightclick)
           .call(force.drag)
           .on("click", (d) -> 
              document.location.href = "/projects/" + commits[0].project_id + "/" + d.path )

nodes.append("title")
     .text((d) -> (if d.path then d.path else d.name) + " " + (if d.metrics && d.metrics[current_metric_id] then d.metrics[current_metric_id] else ""))

force.on("tick", ->
    edges.attr("x1", (d) -> d.source.x)
         .attr("y1", (d) -> d.source.y)
         .attr("x2", (d) -> d.target.x)
         .attr("y2", (d) -> d.target.y)

    nodes.attr("cx", (d) -> d.x)
         .attr("cy", (d) -> d.y)
    )
