return if window.filesToFix == undefined
fixes = d3.select("#five-fixes")

updateFixFileContent = (d) ->
	template = $('#fix-file-template').html()
	commit = d3.select(this.parentNode).datum()
	commit_file = commit_files[d.commit].filter((cf) -> cf.id == d.commit_file_id)[0]
	view = {
		filename: commit_file.path.split("/").splice(-1)[0]
		path: "/projects/" + project.id + "/" + commit_file.path
		score: getMetricScore(file_metrics[commit_file.id], current_metric_id)
		color: color(commit_file)
	}
	Mustache.render(template, view)

window.updateFixFiles = () ->
	fixes.selectAll(".col-md-4").remove()
	fixFiles = fixes.selectAll(".col-md-4")
			.data(filesToFix)

	fixFiles.enter()
			.append("div")
			.attr("class", "col-md-4")
			.html(updateFixFileContent)

watches = d3.select("#five-watches")
window.updateWatchFiles = () ->
	gradientPoints = identifyGradientPoints((a,b) ->
		aDate = new Date(commits.filter((c) -> c.id == a.commit_id)[0].date)
		bDate = new Date(commits.filter((c) -> c.id == b.commit_id)[0].date)
		return bDate - aDate
	)
	filesToWatch = gradientPoints.map((gp) -> {commit: gp.commit_id, commit_file_id: commit_files[gp.commit_id].filter((cf) -> cf.path == gp.path)[0].id})

	watches.selectAll(".col-md-4").remove()
	watchFiles = watches.selectAll(".col-md-4")
			.data(filesToWatch)

	watchFiles.enter()
			.append("div")
			.attr("class", "col-md-4")
			.html(updateFixFileContent)

	gradientPoints



updateFixFiles()
updateWatchFiles()

$('.remove-file').click((e) ->
	if prompt("Why is this file a false positive?")
		$(this).parent().parent().fadeOut())

$('.ok-file').click((e) ->
	$(this).css("color","green"))
	# $(this).parent().parent().fadeOut())