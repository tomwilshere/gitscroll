width = $("#chart-churn").width()
height = $("#chart-churn").height()

svgContainer = d3.select("#chart-churn")
		.append("svg")
		.attr("width", width)
		.attr("height", height)

currentMaxChurn = () ->
	d3.max(Object.keys(pathCount).map((path) -> pathCount[path]))

pathCount = {}
for _, commit of commits
	for _, commit_file of commit_files[commit.id]
		pathCount[commit_file.path] = (pathCount[commit_file.path] || 0) + 1

maxChurn = currentMaxChurn()

updateChurnChart = () ->
	data = Object.keys(pathToCommitFile)

	window.churnCircles = svgContainer.selectAll("circle")
			.data(data)

	complexityScale = d3.scale.linear()
			.domain([currentMin(), currentMax()])
			.range([$("#chart-churn").height(), 0])

	churnScale = d3.scale.linear()
			.domain([0, maxChurn])
			.range([0, $("#chart-churn").width()])

	churnCircles.enter()
			.append("circle")
			.style("fill", (d) -> color(pathToCommitFile[d]))
			.attr("cx", (d) ->
				churnScale(pathCount[d])
			)
			.attr("cy", (d) ->
				complexityScale(getMetricScore(file_metrics[pathToCommitFile[d].id], current_metric_id))
			)
				# complexityScale(getMetricScore(file_metrics[pathToCommitFile[d]], current_metric_id)))
			.attr("r", 5)

	churnCircles.transition()
			.style("fill", (d) -> color(pathToCommitFile[d]))
			.attr("cx", (d) -> churnScale(pathCount[d]))
			.attr("cy", (d) -> complexityScale(getMetricScore(file_metrics[pathToCommitFile[d].id], current_metric_id)))

	churnCircles.exit()
			.remove()

pathToCommitFile = {}
pathCount = {}
commit_number = 0
animation_timer = $.timer(->
	processCommitChurn()
	commit_number++
	animation_timer.stop() if commit_number == commits.length - 1
	return)
window.startChurnAnimation = () ->
	animation_timer.set({time: 15000/commits.length, autostart: true})

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
		pathToCommitFile[commit_file.path] = commit_file
	updateChurnChart()

$('#churn-play').click(startChurnAnimation)
$('#churn-pause').click(pauseChurnAnimation)
$('#churn-stop').click(stopChurnAnimation)


