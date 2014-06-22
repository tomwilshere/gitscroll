gradientSort = (a,b) ->
	b.gradient - a.gradient

window.identifyGradientPoints = (sortFunction = gradientSort) ->
	pathMaxGradients = new Array()
	for path of commit_files_by_path
		if path.indexOf(window.path) == 0
			pathDifference = 0
			pathCommitId = null
			cfs = commit_files_by_path[path]
			metrics = cfs.map((cf) -> {commit: cf.commit_id, score: getMetricScore(file_metrics[cf.id],current_metric_id)})
			if metrics.length > 1
				i = 1
				while i < metrics.length
					difference = metrics[i].score - metrics[i-1].score
					if difference && difference >= pathDifference
						pathDifference = difference
						pathCommitId = metrics[i].commit
					i++
			if pathCommitId
				pathMaxGradients.push({path: path, commit_id: pathCommitId, gradient: pathDifference})
	return pathMaxGradients.sort(sortFunction)
