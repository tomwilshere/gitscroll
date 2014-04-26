metric_selector = d3.select("#metric_id_metric_name")

mins = []
maxs = []

metric_selector.selectAll("option").each () ->
  metric_id = this.value
  mins[metric_id] = d3.min(commits.map($.parseJSON)[0].nodes, (d) -> if (d.metrics && d.metrics[metric_id]) then d.metrics[metric_id] else null)
  maxs[metric_id] = d3.max(commits.map($.parseJSON)[0].nodes, (d) -> if (d.metrics && d.metrics[metric_id]) then d.metrics[metric_id] else null)

window.current_metric_id = 1

min = mins[current_metric_id]
max = maxs[current_metric_id]

window.color = (d) ->
  if (d && d.metrics && d.metrics[current_metric_id])
    return red_green_scale(d.metrics[current_metric_id])
  return "#ccc"

red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])

metric_selector.on("change", () ->
  window.current_metric_id = this.value
  min = mins[current_metric_id]
  max = maxs[current_metric_id]
  red_green_scale = d3.scale.sqrt()
            .domain([0,0.5,1].map(d3.interpolate(min, max)))
            .range(["green","yellow","red"])
  nodes.transition().style("fill", (d) -> color(d))
  files.style("fill", (d) -> color(d)) #add transition here when it doesn't create a massive lag
)
	