return if window.commits == undefined

# redraw function for panning and zooming
redraw = () ->
    svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
    return

Object.size = (obj) ->
  size = 0
  key = undefined
  for key of obj
    size++  if obj.hasOwnProperty(key)
  size

tip = d3.tip()
        .attr('class', 'd3-tip')
        .offset([-10,0-$("#chart-network").width()/2])
        # .direction('w')
        .html((d) ->
            console.log d
            if file_metrics && d && file_metrics[d.id] && file_metrics[d.id].filter((fm) -> fm.metric_id == current_metric_id)[0]
                "File: " +
                d.path +
                "<br>Score: " +
                getMetricScore(file_metrics[d.id],current_metric_id) + 
                # " commit hash: " +
                # d3.select(this.parentNode).datum().git_hash +
                " commit message: " +
                d3.select(this.parentNode).datum().message
                # " date: " +
                # d3.select(this.parentNode).datum().date.to_s
        )


width = 1000
height = 400

svgContainer = d3.select("#chart-lifeline")
        .append("svg")
        .attr("width", $("#chart-network").width())
        .attr("height", height)
        .call(d3.behavior.zoom().scaleExtent([1,Infinity]).on("zoom", redraw));

svg = svgContainer.append('svg:g')

svg.call(tip)

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
		.data((d) -> commit_files[d.git_hash] || [])#commit_files.filter((n) -> n.commit_id == d.git_hash && n.path.indexOf(path) == 0))
		.enter()
		.append("rect")
		.style("fill", (d) -> color(d)
		)
		.attr("height", 2)
		.attr("width", "100%")
		.attr("x", (d) ->
			commit_scale(d3.select(this.parentNode).datum().index)
		)
		.attr("y", (d, i) -> file_scale(d.path))
        .on('mouseover', tip.show)
        .on('mouseout', tip.hide)
		# .on("click", (d) -> document.location.href = "/projects/" + d3.select(this.parentNode).datum().project_id + "/" + d.path )
		
window.deletions = commit_groups.selectAll("rect.deletions")
		.data((d) ->
			if d.deleted_files && d.deleted_files != ""
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

# files.append("title")
# 		.text((d) ->
# 			if file_metrics && d && file_metrics[d.id] && file_metrics[d.id].filter((fm) -> fm.metric_id == current_metric_id)[0]
# 				"File: " +
# 				d.path +
# 				" score: " +
# 				file_metrics[d.id].filter((fm) -> fm.metric_id == current_metric_id)[0].score +
# 				" commit hash: " +
# 				d3.select(this.parentNode.parentNode).datum().git_hash +
# 				" commit message: " +
# 				d3.select(this.parentNode.parentNode).datum().message +
# 				" date: " +
# 				d3.select(this.parentNode.parentNode).datum().date
# 			)

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

window.identifyGradientPoints = () ->
	pathMaxGradients = new Array()
	for path of commit_files_by_path
		pathDifference = 0
		pathCommitId = null
		cfs = commit_files_by_path[path]
		metrics = cfs.map((cf) -> {commit: cf.commit_id, score: getMetricScore(file_metrics[cf.id],current_metric_id)})
		if metrics.length > 1
			i = 1
			while i < metrics.length
				difference = metrics[i].score - metrics[i-1].score
				if difference > pathDifference
					pathDifference = difference 
					pathCommitId = metrics[i].commit
				i++
		if pathCommitId
			pathMaxGradients.push({path: path, commit_id: pathCommitId, gradient: pathDifference})
	gradientPoints = pathMaxGradients.sort((a,b) -> b.gradient - a.gradient).slice(0,5)

	svg.selectAll("circle").remove()
	gradientCircles = svg.selectAll("circle")
			.data(gradientPoints)
			.enter()
			.append("circle")
			.style("fill", "none")
			.style("stroke", "red")
			.style("stroke-width", "2")
			.attr("cx", (d) -> commit_scale(commits.filter((c) -> c.id == d.commit_id)[0].index))
			.attr("cy", (d) -> update_file_scale(file_scale(d.path)) + ($("#chart-lifeline").height() / Object.size(file_ordering))/2)
			.attr("r", 10)

identifyGradientPoints()
