return if window.commits == undefined

if commits.length < project.num_commits
	$('#progress').removeClass("hidden")
	d3.select('#progress-bar').transition().style("width", (commits.length / project.num_commits) * 100 + "%")

# redraw function for panning and zooming
redraw = () ->
    svg.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
    return

window.Object.size = (obj) ->
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
            if getMetricScore(file_metrics[d.id], current_metric_id)
                "File: " +
                d.path +
                "<br>Score: " +
                getMetricScore(file_metrics[d.id],current_metric_id) + 
                " commit message: " +
                d3.select(this.parentNode).datum().message
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
	gradientPoints = pathMaxGradients.sort((a,b) -> b.gradient - a.gradient).slice(0,$('#gradient-points').val())

	gradientCircles = svg.selectAll("circle")
			.data(gradientPoints, (d) -> d.path + "@" + d.commit_id)

	gradientCircles.enter()
			.append("circle")
			.style("fill", "none")
			.style("stroke", "blue")
			.style("stroke-width", "2")
			.attr("cx", (d) -> commit_scale(commits.filter((c) -> c.id == d.commit_id)[0].commit_number))
			.attr("cy", (d) -> file_scale(d.path) + ($("#chart-lifeline").height() / Object.size(file_ordering))/2)
			.attr("r", 10)
	gradientCircles.exit()
			.remove()

	gradientCircles.transition()
			.attr("cx", (d) -> commit_scale(commits.filter((c) -> c.id == d.commit_id)[0].commit_number))
			.attr("cy", (d) -> file_scale(d.path) + ($("#chart-lifeline").height() / Object.size(file_ordering))/2)

	gradientPoints

window.file_ordering = {}

refreshLifelineData = () ->

	window.file_scale = (path) ->
		if file_ordering[path] == undefined
			file_ordering[path] = Object.size(file_ordering)
		new_scale = d3.scale.linear()
				.domain([0, Object.size(file_ordering)])
				.range([0, $("#chart-lifeline").height()])
		return new_scale(file_ordering[path])

	window.commit_scale = d3.scale.linear()
			.domain([0, commits.length])
			.range([0, $("#chart-lifeline").width()])

	window.commit_groups = svg.selectAll("g")
			.data(commits, (d) -> d.id)

	commit_groups.enter()
			.append("g")

	commit_groups.exit()
			.remove()

	window.files = commit_groups.selectAll("rect.commit_files")
			.data(((d) -> commit_files[d.git_hash] || []), (d) -> d.id)

	files.enter()
			.append("rect")
			.attr("class", "commit_files")
			.style("fill", (d) -> 
				color(d)
			)
			.attr("height", 2)
			.attr("width", "100%")
			.attr("x", (d) ->
				commit_scale(d3.select(this.parentNode).datum().commit_number)
			)
			.attr("y", (d, i) -> file_scale(d.path))
	        .on('mouseover', tip.show)
	        .on('mouseout', tip.hide)
			# .on("click", (d) -> document.location.href = "/projects/" + d3.select(this.parentNode).datum().project_id + "/" + d.path )

	files.transition()
			.attr("x", (d) ->
				commit_scale(d3.select(this.parentNode).datum().commit_number)
			)
			.attr("y", (d, i) -> file_scale(d.path))
			.style("fill", (d) -> color(d))



	files.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))	

	window.deletions = commit_groups.selectAll("rect.deletions")
			.data(((d) ->
				if d.deleted_files && d.deleted_files != ""
					d.deleted_files.split(",")
						.filter((df) -> df.indexOf(path) == 0)
						.map((df) -> {commit: d, deleted_file: df}) 
				else
					[]
				), (d) -> d.commit.index + d.deleted_file)

	deletions.enter()
			.append("rect")
			.attr("class", "deletions")
			.style("fill", "white")
			.attr("height", 1)
			.attr("width", "100%")
			.attr("x", (d) ->
				commit_scale(d.commit.commit_number)
			)
			.attr("y", (d) -> 
				file_scale(d.deleted_file)
			)

	deletions.transition()
			.attr("x", (d) ->
				commit_scale(d.commit.commit_number)
			)
			.attr("y", (d) -> 
				file_scale(d.deleted_file)
			)

	deletions.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))

	identifyGradientPoints()

refreshLifelineData()

deletions.attr("y", (d) -> file_scale(d.deleted_file))
		.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))

$('#gradient-points').on("change mousemove", () -> 
    identifyGradientPoints()
    $('#gradient-points-count').html($(this).val())
)

refreshData = () ->
	$.getJSON("/projects/" + project.id + ".json", updateLifeline)

updateLifeline = (data) ->
	window.commits = data.commits
	window.commit_files = data.commit_files
	window.file_metrics = data.file_metrics
	window.commit_files_by_path = data.commit_files_by_path
	checkAndCalculateMetricStats(true)
	refreshLifelineData()
	if window.nodes != undefined
		nodes.attr("fill", (d) -> color(d))
	d3.select('#progress-bar').transition().style("width", (commits.length / project.num_commits) * 100 + "%")
	if commits.length < project.num_commits
		refreshData()
	else
		$('#progress-bar').hide()

refreshData()
