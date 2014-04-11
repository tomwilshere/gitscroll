# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

width = 1000
height = 500

color = d3.scale.category10()

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
		.attr("width", width)
		.attr("height", height)

force = d3.layout.force()
		  .nodes(dataset.nodes)
		  .links(edges)
		  .size([width,height])
		  .start()

edges = svg.selectAll("line")
		   .data(edges)
		   .enter()
		   .append("line")
		   .style("stroke", "#ccc")
		   .style("stroke-width", 1)

nodes = svg.selectAll("circle")
		   .data(dataset.nodes)
		   .enter()
		   .append("circle")
		   .attr("r", (d) -> d.size)
		   .style("fill", (d,i) -> color(i))
		   .call(force.drag)

nodes.append("title")
	 .text((d) -> d.name)

force.on("tick", ->
	edges.attr("x1", (d) -> d.source.x)
	     .attr("y1", (d) -> d.source.y)
	     .attr("x2", (d) -> d.target.x)
	     .attr("y2", (d) -> d.target.y)

	nodes.attr("cx", (d) -> d.x)
	     .attr("cy", (d) -> d.y)
	)