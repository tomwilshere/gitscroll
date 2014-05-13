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

dataset = commits#.sort((a,b) -> new Date(a.date) - new Date(b.date))

min = d3.min(commits, (c) -> new Date(c.date))
max = d3.max(commits, (c) -> new Date(c.date))

commit_scale = d3.scale.linear()
		.domain([0, dataset.length])
		.range([0, $("#chart-lifeline").width()])

file_ordering = {}

file_scale = (path) ->
	if file_ordering[path] == undefined
		file_ordering[path] = Object.size(file_ordering)
	return file_ordering[path]

commit_groups = svg.selectAll("g")
		.data(dataset)
		.enter()
		.append("g")
		.each((d,i) -> d.index = i)

window.files = commit_groups.selectAll("rect.commit_files")
		.data((d) -> commit_files.filter((n) -> n.commit_id == d.git_hash && n.path.indexOf(path) == 0))
		.enter()
		.append("rect")
		.style("fill", (d) -> color(d))
		.attr("height", 2)
		.attr("width", "100%")
		.attr("x", (d) ->
			commit_scale(d3.select(this.parentNode).datum().index)
		)
		.attr("y", (d, i) -> file_scale(d.path))
		.on("click", (d) -> document.location.href = "/projects/" + d3.select(this.parentNode).datum().project_id + "/" + d.path )
		
window.deletions = commit_groups.selectAll("rect.deletions")
		.data((d) ->
			if d.deleted_files != "" 
				d.deleted_files.split(",")
					.filter((df) -> df.indexOf(path) == 0)
					.map((df) -> {commit: d, deleted_file: df}) 
			else 
				[]
			)
		.enter()
		.append("rect")
		.style("fill", "white")
		.attr("height", 1)
		.attr("width", "100%")
		.attr("x", (d) ->
			commit_scale(d.commit.index)
		)
		.attr("y", (d) -> 
			file_scale(d.deleted_file)
		)

files.append("title")
		.text((d) ->
			if file_metrics && d && file_metrics[d.id] && file_metrics[d.id][current_metric_id]
				"File: " +
				d.path +
				" score: " +
				file_metrics[d.id][current_metric_id].score +
				" commit hash: " +
				d3.select(this.parentNode.parentNode).datum().git_hash +
				" commit message: " +
				d3.select(this.parentNode.parentNode).datum().message +
				" date: " +
				d3.select(this.parentNode.parentNode).datum().date
			)

deletions.append("title")
		.text((d) ->
			"File: " +
			d.deleted_file +
			" Deleted" + 
			" commit message: " +
			d3.select(this.parentNode.parentNode).datum().message +
			" date: " +
			d3.select(this.parentNode.parentNode).datum().date
		)

update_file_scale = d3.scale.linear()
	.domain([0, Object.size(file_ordering)])
	.range([0, $("#chart-lifeline").height()])

files.attr("y", (d) -> update_file_scale(file_scale(d.path)))
		.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))	
		# .attr("width", $("#chart-lifeline").width() / dataset.length)

deletions.attr("y", (d) -> update_file_scale(file_scale(d.deleted_file)))
		.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))

