return if !window.project?
window.getMetricScore = (file_metric, metric_id) ->
  try
    return file_metric[metric_id].score
  catch
    return null

metric_selector = d3.select("#metric_id_metric_name")
project_selector = d3.select("#project_id_project_name")

window.current_metric_id = 1
window.current_compare_project_id = project.id

window.checkAndCalculateMetricStats = (force = false) ->
  if !metric_stats[current_compare_project_id] || (force && project.id == current_compare_project_id)
    metric_array = new Array();

    for key of file_metrics
      metric_array.push(file_metrics[key])

    metric_stats[current_compare_project_id] = new Array

    metric_selector.selectAll("option").each () ->
      metric_id = parseInt(this.value)
      min = d3.min(metric_array, (d) -> getMetricScore(d, metric_id))
      max = d3.max(metric_array, (d) -> getMetricScore(d, metric_id))
      metric_stats[current_compare_project_id][metric_id-1] = {min: min, max: max}

  return metric_stats[current_compare_project_id][current_metric_id-1]

window.currentMin = () ->
  checkAndCalculateMetricStats().min

window.currentMax = () ->
  checkAndCalculateMetricStats().max

refreshScale = () ->
  d3.scale.sqrt()
      .domain([0,0.5,1].map(d3.interpolate(currentMin(), currentMax())))
      .range(["green","yellow","red"])

window.color = (commit_file) ->
  score = getMetricScore(file_metrics[commit_file.id],current_metric_id)
  if score != null
    red_green_scale = refreshScale()
    return red_green_scale(score)
  else
    return "#ccc"

metric_selector.on("change", () ->
  window.current_metric_id = parseInt(this.value)
  if window.nodes
    nodes.transition().style("fill", (d) -> color(d))
  if window.files
    files.transition().style("fill", (d) -> color(d))
  updateGradientCircles()
  updateFixFiles()
  updateWatchFiles()
  stopChurnAnimation()
  startChurnAnimation()
  analytics.track('Changed metric dropdown', {
    metric  : current_metric_id
  });
)

project_selector.on("change", () ->
  window.current_compare_project_id = parseInt(this.value)
  min = metric_stats[current_compare_project_id][current_metric_id - 1].min
  max = metric_stats[current_compare_project_id][current_metric_id - 1].max
  if window.nodes != undefined
    nodes.transition().style("fill", (d) -> color(d))
  if window.files != undefined
    files.transition().style("fill", (d) -> color(d))
  updateFixFiles()
  updateWatchFiles()
  analytics.track('Changed project dropdown', {
    metric  : current_compare_project_id
  });
)