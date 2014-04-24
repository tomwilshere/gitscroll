return if window.commits == undefined

Object.size = (obj) ->
  size = 0
  key = undefined
  for key of obj
    size++  if obj.hasOwnProperty(key)
  size

width = 1000
height = 400

svg = d3.select("#chart-lifeline")
        .append("svg")
        .attr("width", $("#chart-network").width())
        .attr("height", height)

dataset = commits.map($.parseJSON)



commit_scale = d3.scale.linear()
		.domain([0, dataset.length])
		.range([$("#chart-lifeline").width(), 0])

file_ordering = {}

file_scale = (node) ->
	if file_ordering[node.path] == undefined
		file_ordering[node.path] = Object.size(file_ordering)
	return file_ordering[node.path]

commit_groups = svg.selectAll("g")
		.data(dataset)
		.enter()
		.append("g")

window.files = commit_groups.selectAll("rect")
		.data((d,index) -> d.nodes.filter (n) -> n.size == 4 )#&& n.metrics[current_metric_id])
		.enter()
		.append("rect")
		.style("fill", (d) -> color(d))
		.attr("height", 2)
		.attr("width", 2)
		.attr("x", (d, i) -> 
			commit_scale(d3.select(this.parentNode).datum().commit_number-1)
		)
		.attr("y", (d, i) -> file_scale(d) * 5)
		
files.append("title")
		.text((d) ->
			"File: " +
			d.path +
			" score: " +
			d.metrics[current_metric_id] +
			" commit message: " +
			d3.select(this.parentNode.parentNode).datum().message
			)

update_file_scale = d3.scale.linear()
	.domain([0, Object.size(file_ordering)])
	.range([0, $("#chart-lifeline").height()])

files.attr("y", (d) -> update_file_scale(file_scale(d)))
		.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))	
		.attr("width", $("#chart-lifeline").width() / dataset.length)


