return if window.commits == undefined

if commits.length < project.num_commits
	$('#progress').removeClass("hidden")
	d3.select('#progress-bar').transition().style("width", (commits.length / project.num_commits) * 100 + "%")

$(window).resize ->
	refreshLifelineData()

tip = d3.tip()
		.attr('class', 'd3-tip')
		.offset([-10,0-$("#chart-lifeline").width()/2])
		.html((d) ->
			template = $('#tip-template').html()
			commit = d3.select(this.parentNode).datum()
			score = getMetricScore(file_metrics[d.id], current_metric_id)
			score = "Not Calculated" if score == null
			view = {
				author: authors[commit.author_id]
				filename: d.path.split("/").slice(-1)[0]
				score: score
				commit_message: commit.message
				metric_name: $('#metric_id_metric_name option:selected').text()
				commit_date: new Date(commit.date).toUTCString()
			}
			Mustache.render(template, view)
		)


width = $("#chart-lifeline").width()
height = $("#chart-lifeline").height()
axisHeight = 30

svgContainer = d3.select("#chart-lifeline")
		.append("svg")
		.attr("width", width)
		.attr("height", height + axisHeight)

window.commit_scale = d3.scale.linear()
		.domain([0, commits.length])
		.range([5, $("#chart-lifeline").width()])


axis = d3.svg.axis().scale(commit_scale)

svgContainer.append("g")
		.attr("class", "axis")
		.attr("transform", "translate(0," + height + ")")
		.call(axis)

svg = svgContainer.append('svg:g')


svg.call(tip)

window.updateGradientCircles = () ->
	gradientPoints = identifyGradientPoints().slice(0,$('#gradient-points').val())
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
			.attr("cx", (d) ->
				commit_scale(commits.filter((c) -> c.id == d.commit_id)[0].commit_number))
			.attr("cy", (d) -> file_scale(d.path) + ($("#chart-lifeline").height() / Object.size(file_ordering))/2)

	gradientPoints

window.file_ordering = {}

window.refreshLifelineData = () ->
	svgContainer.attr("width", $('#chart-lifeline').width())
		.attr("height", $('#chart-lifeline').height() + axisHeight)

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
			.data(((d) ->
				cfs = commit_files[d.git_hash] || []
				if cfs
					cfs = cfs.filter((cf) -> cf.path.indexOf(path) == 0 )
			), (d) -> d.id)

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

	updateGradientCircles()

refreshLifelineData()

deletions.attr("y", (d) -> file_scale(d.deleted_file))
		.attr("height", $("#chart-lifeline").height() / Object.size(file_ordering))

$('#gradient-points').on("change", () ->
	updateGradientCircles()
	$('#gradient-points-count').html($(this).val())
	analytics.track('gradient circles updated', {
		numGradientPoints  : $(this).val()
	});
)

$('#gradient-points').on("mousemove", () ->
	updateGradientCircles()
	$('#gradient-points-count').html($(this).val()))

refreshData = () ->
	if commits.length < project.num_commits
		$.getJSON("/projects/" + project.id + ".json", updateLifeline)
	else
		$('#progress-bar').hide()

updateLifeline = (data) ->
	window.commits = data.commits
	window.commit_files = data.commit_files
	window.file_metrics = data.file_metrics
	window.commit_files_by_path = data.commit_files_by_path
	window.authors = data.authors
	checkAndCalculateMetricStats(true)
	refreshLifelineData()
	if window.nodes != undefined
		nodes.attr("fill", (d) -> color(d))
	d3.select('#progress-bar').transition().style("width", (commits.length / project.num_commits) * 100 + "%")
	refreshData()

refreshData()
