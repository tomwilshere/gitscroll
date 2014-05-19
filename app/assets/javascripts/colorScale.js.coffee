window.getMetricScore = (file_metric, metric_id) ->
  try
    return file_metric.filter((fm) -> fm.metric_id == metric_id)[0].score
  catch
    return null

metric_selector = d3.select("#metric_id_metric_name")
project_selector = d3.select("#project_id_project_name")

window.mins = []
window.maxs = []

window.metric_array = new Array();

for key of file_metrics
  metric_array.push(file_metrics[key])

metric_selector.selectAll("option").each () ->
  metric_id = parseInt(this.value)
  mins[metric_id] = d3.min(metric_array, (d) -> getMetricScore(d, metric_id))
  maxs[metric_id] = d3.max(metric_array, (d) -> getMetricScore(d, metric_id))

window.current_metric_id = 1

min = mins[current_metric_id]
max = maxs[current_metric_id]


red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
window.color = (commit_file) ->
  score = getMetricScore(file_metrics[commit_file.id],current_metric_id)
  if score
    return red_green_scale(score)
  else
    return "#ccc"

metric_selector.on("change", () ->
  window.current_metric_id = parseInt(this.value)
  min = mins[current_metric_id]
  max = maxs[current_metric_id]
  red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
  nodes.transition().style("fill", (d) -> color(d))
  files.transition().style("fill", (d) -> color(d))
)
  
project_selector.on("change", () -> 
  project_id = parseInt(this.value)
  min = metric_stats[project_id][current_metric_id - 1].min
  max = metric_stats[project_id][current_metric_id - 1].max
  red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
  nodes.transition().style("fill", (d) -> color(d))
  files.transition().style("fill", (d) -> color(d))
)