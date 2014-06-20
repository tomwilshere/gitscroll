if metric_stats.length == 0
	$("#file-view-chart").hide()
	return

width = $("#file-view-chart").width()
height = $("#file-view-chart").height()
axisHeight = 30
leftMargin = 75
bottomMargin = 70
topMargin = 50
rightMargin = 50
labelOffset = 15
metric_color_block_dimensions = 14

current_metric = 1
raw_scores = []
for k,v of file_metrics
	raw_scores = raw_scores.concat(v.map((d) -> d.score))
get_stats = (metric) ->
	metric_stats.filter((ms) -> ms.metric_id == metric)[0]

mousemoveEvent = (d, i) ->
	xPos = d3.mouse(this)[0]
	return if xPos < leftMargin || xPos > width - rightMargin
	newHash = hash_array[Math.floor(inverse_commit_scale(xPos))]
	if newHash != window.currentHash
		jumpTo(newHash)
	hoverLine.attr("x1", xPos)
	hoverLine.attr("x2", xPos)

window.updateHoverLine = (hash) ->
	hoverLine.attr("x1", commit_scale(hash_array.indexOf(hash)))
	hoverLine.attr("x2", commit_scale(hash_array.indexOf(hash)))

minMetric = () ->
	Math.min.apply(null, raw_scores)

maxMetric = () ->
	Math.max.apply(null, raw_scores)

updateMetricScale = () ->
	d3.scale.linear()
		.domain([minMetric(), maxMetric()])
		.range([height - bottomMargin , topMargin])

metric_scale = updateMetricScale()

svgContainer = d3.select("#file-view-chart").append("svg")
		.attr("width", width)
		.attr("height", height)
		.on("mousemove", mousemoveEvent)

svg = svgContainer.append("g")

metrics = window.metrics.filter((m) -> get_stats(m.id).min != null)

commit_scale = d3.scale.linear()
		.domain([0, hash_array.length])
		.range([leftMargin, width - rightMargin])

inverse_commit_scale = d3.scale.linear()
		.domain([leftMargin, width - rightMargin])
		.range([0, hash_array.length])

xAxis = d3.svg.axis().scale(commit_scale)
yAxis = d3.svg.axis().scale(metric_scale).orient("left")

svgXaxis = svgContainer.append("g")
		.attr("class", "axis")
		.attr("transform", "translate(0," + (height - bottomMargin) + ")")
		.call(xAxis)

svgYaxis = svgContainer.append("g")
		.attr("class", "axis")
		.attr("transform", "translate(" + leftMargin + ",0)")
		.call(yAxis)


metric_color_scale = d3.scale.category10()

lineFunction = (metric_id) ->
	d3.svg.line()
		.x((commit_id) -> commit_scale(hash_array.indexOf(commit_id)))
		.y((commit_id) ->
			score = file_metrics[commit_files[commit_id]].filter((fm) -> fm.metric_id == metric_id)[0].score
			current_metric = metric_id
			metric_scale = updateMetricScale()
			metric_scale(score)
			# file_metrics[commit_files[commit_id]].filter((fm) -> fm.metric_id == metric_id)[0].score
		)
		.interpolate("linear")

window.metricGroups = svg.selectAll("g.metric-group")
		.data(metrics)

metricGroups.enter()
		.append("path")
		.attr("d", (d) ->
			lf = lineFunction(d.id)
			lf(hash_array))
		.attr("stroke", (d) -> metric_color_scale(d.id))
		.attr("stroke-width", "2px")
		.attr("fill", "none")

hoverLine = svg.append("line")
		.attr("x1", commit_scale(hash_array.indexOf(currentHash)))
		.attr("y1", topMargin)
		.attr("x2", commit_scale(hash_array.indexOf(currentHash)))
		.attr("y2", height - bottomMargin)
		.attr("stroke", "#ccc")

metric_label_scale = d3.scale.linear()
		.domain([1,metrics.length + 1])
		.range([leftMargin + 30, width - rightMargin - 30])

for metric in metrics
	svg.append("rect")
		.attr("width", metric_color_block_dimensions)
		.attr("height", metric_color_block_dimensions)
		.attr("x", metric_label_scale(metric.id))
		.attr("y", labelOffset)
		.attr("fill", metric_color_scale(metric.id))
	svg.append("text")
		.attr("x", metric_label_scale(metric.id) + 20)
		.attr("y", labelOffset + 12)
		.text(metric.name)

# window.files = metricGroups.selectAll("rect")
# 		.data(hash_array)

# files.enter()
# 		.append("rect")
# 		.attr("width", "100%")
# 		.attr("height", height / metrics.length * 0.6)
# 		.attr("x", (d) -> commit_scale(hash_array.indexOf(d)))
# 		.attr("y", (d) -> metric_scale(d3.select(this.parentNode).datum().id - 1) + 0.2 * height/metrics.length)
# 		.attr("fill", (d) ->
# 				metric_id = d3.select(this.parentNode).datum().id
# 				file_metric = file_metrics[commit_files[d]].filter((fm) -> fm.metric_id == metric_id)[0]
# 				if file_metric
# 					color_scale(metric_id, file_metric.score)
# 				else
# 					"#ccc"
# 		)
