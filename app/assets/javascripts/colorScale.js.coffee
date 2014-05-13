metric_selector = d3.select("#metric_id_metric_name")

mins = []
maxs = []

metric_array = new Array();

for key of file_metrics
  metric_array.push(file_metrics[key])

metric_selector.selectAll("option").each () ->
  metric_id = this.value
  mins[metric_id] = d3.min(metric_array, (d) -> if (d[metric_id]) then d[metric_id].score else null)
  maxs[metric_id] = d3.max(metric_array, (d) -> if (d[metric_id]) then d[metric_id].score else null)

window.current_metric_id = 1

min = mins[current_metric_id]
max = maxs[current_metric_id]


red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
window.color = (commit_file) ->
  if (file_metrics[commit_file.id] && 
      file_metrics[commit_file.id].filter((fm) -> fm.metric_id == current_metric_id) &&
      file_metrics[commit_file.id].filter((fm) -> fm.metric_id == current_metric_id)[0])
    return red_green_scale(file_metrics[commit_file.id].filter((fm) -> fm.metric_id == current_metric_id)[0].score)
  return "#ccc"

metric_selector.on("change", () ->
  window.current_metric_id = parseInt(this.value)
  min = mins[current_metric_id]
  max = maxs[current_metric_id]
  red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
  nodes.transition().style("fill", (d) -> color(d))
  files.transition().style("fill", (d) -> color(d)) #add transition here when it doesn't create a massive lag
)
	