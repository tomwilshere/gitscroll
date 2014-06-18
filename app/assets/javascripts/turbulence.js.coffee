return if window.commits == undefined
width = $("#chart-churn").width()
height = $("#chart-churn").height()
axisHeight = 30
axisWidth = 50
churnStepLength = 15000/commits.length

svgContainer = d3.select("#chart-churn")
		.append("svg")
		.attr("width", width + axisWidth)
		.attr("height", height + axisHeight)

currentMaxChurn = () ->
	d3.max(Object.keys(pathCount).map((path) -> pathCount[path]))

pathCount = {}
for _, commit of commits
	for _, commit_file of commit_files[commit.id]
		pathCount[commit_file.path] = (pathCount[commit_file.path] || 0) + 1

maxChurn = currentMaxChurn()

tip = d3.tip()
		.attr('class', 'd3-tip')
		.offset([-10,0])
		# .on("click", (d) ->	document.location.href = "/projects/" + project.id + "/" + d.path + "#" + d.commit.id )
		.html((d) ->
			template = $('#tip-template').html()
			commit = d.commit
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
svgContainer.call(tip)

svgXaxis = svgContainer.append("g")
		.attr("class", "axis")
		.attr("transform", "translate(0," + height + ")")

svgYaxis = svgContainer.append("g")
		.attr("class", "axis")
		.attr("transform", "translate("+ axisWidth + ",0)")

updateChurnChart = () ->
	data = Object.keys(pathToCommitFile).map((path) -> pathToCommitFile[path])

	window.churnCircles = svgContainer.selectAll("circle")
			.data(data)

	complexityScale = d3.scale.linear()
			.domain([currentMin(), currentMax()])
			.range([$("#chart-churn").height()-7 , 7])

	churnScale = d3.scale.linear()
			.domain([0, maxChurn])
			.range([5 + axisWidth, $("#chart-churn").width()-5])

	xaxis = d3.svg.axis().scale(churnScale)
	svgXaxis.call(xaxis)

	yaxis = d3.svg.axis().scale(complexityScale).orient("left")
	svgYaxis.call(yaxis)

	churnCircles.enter()
			.append("circle")
			.style("fill", (d) -> color(d))
			.attr("cx", (d) ->
				churnScale(pathCount[d.path])
			)
			.attr("cy", (d) ->
				complexityScale(getMetricScore(file_metrics[d.id], current_metric_id))
			)
				# complexityScale(getMetricScore(file_metrics[pathToCommitFile[d]], current_metric_id)))
			.attr("r", 5)
			.on('mouseover', tip.show)
			.on('mouseout', tip.hide)
			.on("click", (d) ->	document.location.href = "/projects/" + project.id + "/" + d.path + "#" + d.commit.id )

	churnCircles.transition()
			.duration(churnStepLength*5)
			.style("fill", (d) -> color(d))
			.attr("cx", (d) -> churnScale(pathCount[d.path]))
			.attr("cy", (d) -> complexityScale(getMetricScore(file_metrics[d.id], current_metric_id)))

	churnCircles.exit()
			.remove()

pathToCommitFile = {}
pathCount = {}
commit_number = 0
animation_timer = $.timer(->
	processCommitChurn()
	commit_number++
	if commit_number == commits.length - 1
		animation_timer.stop()
		commit_number = 0
		pathToCommitFile = {}
		pathCount = {}
	return)
window.startChurnAnimation = () ->
	updateChurnChart()
	animation_timer.set({time: churnStepLength, autostart: true})

pauseChurnAnimation = () ->
	animation_timer.pause()

window.stopChurnAnimation = () ->
	animation_timer.stop()
	pathToCommitFile = {}
	pathCount = {}
	commit_number = 0
	svgContainer.selectAll("circle").remove()

startChurnAnimation()

processCommitChurn = () ->
	commit = commits[commit_number]
	for _, commit_file of commit_files[commit.id]
		# increment path count for this commit file's path
		pathCount[commit_file.path] = (pathCount[commit_file.path] || 0) + 1
		# update the path to commit_file hash
		commit_file.commit = commit
		pathToCommitFile[commit_file.path] = commit_file
	updateChurnChart()

$('#churn-play').click(() ->
	startChurnAnimation()
	analytics.track('play animation', {
		commit_number  : commit_number,
		num_commits : commits.length
	});
)

$('#churn-pause').click(() ->
	pauseChurnAnimation()
	analytics.track('pause animation', {
		commit_number  : commit_number,
		num_commits : commits.length
	});
)
$('#churn-stop').click(() ->
	stopChurnAnimation()
	analytics.track('stop animation', {
		commit_number  : commit_number,
		num_commits : commits.length
	});
)


