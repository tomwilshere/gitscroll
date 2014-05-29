return if window.filesToFix == undefined
fixes = d3.select("#five-fixes")

updateFileContent = (d, type) ->
	template = $('#fix-file-template').html()
	commit_file = commit_files[d.commit].filter((cf) -> cf.id == d.commit_file_id)[0]
	view = {
		filename: commit_file.path.split("/").splice(-1)[0]
		path: commit_file.path
		url_path: "/projects/" + project.id + "/" + commit_file.path
		score: getMetricScore(file_metrics[commit_file.id], current_metric_id)
		color: color(commit_file)
		type: type
	}
	Mustache.render(template, view)

updateFixFileContent = (d) ->
	updateFileContent(d, "fix")

updateWatchFileContent = (d) ->
	updateFileContent(d, "watch")

window.updateFixFiles = () ->
	window.false_positive_paths = falsePositives.filter((fp) -> fp.type == "fix").map((fp) -> fp.path)
	data = filesToFix.filter((file) -> !(file.path in false_positive_paths))
	fixes.selectAll(".col-md-4").remove()
	fixFiles = fixes.selectAll(".col-md-4")
			.data(data)

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
	false_positive_paths = falsePositives.filter((fp) -> fp.type == "watch").map((fp) -> fp.path)
	gradientPoints = gradientPoints.filter((file) -> !(file.path in false_positive_paths))
	filesToWatch = gradientPoints.map((gp) -> {commit: gp.commit_id, commit_file_id: commit_files[gp.commit_id].filter((cf) -> cf.path == gp.path)[0].id})

	watches.selectAll(".col-md-4").remove()
	watchFiles = watches.selectAll(".col-md-4")
			.data(filesToWatch)

	watchFiles.enter()
			.append("div")
			.attr("class", "col-md-4")
			.html(updateWatchFileContent)

	gradientPoints



updateFixFiles()
updateWatchFiles()

$('.remove-file').click((e) ->
	comment = prompt("Why is this file a false positive?")
	if comment
		$('#false_positive_project_id').val(project.id)
		$('#false_positive_comment').val(comment)
		$('#false_positive_path').val($(this).data("path"))
		$('#false_positive_type').val($(this).data("type"))
		$('#new_false_positive').submit()
		$(this).parent().parent().fadeOut()
		analytics.track('False positive file suggest', {
			type: $(this).data("type"),
			path: $(this).data("path")
		});
)

$('.ok-file').click((e) ->
	$(this).css("color","green")
	analytics.track('Awknowledged file suggest', {
		type: $(this).data("type"),
		path: $(this).data("path")
	});
)