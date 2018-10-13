// https://beta.observablehq.com/@mbostock/d3-area-chart
// https://beta.observablehq.com/@mbostock/d3-line-chart

// example values
// const values = JSON.parse( "[]]")

// data = values.map(({date, value}) => {
//   const dateArray = date.split('-');
//   date = new Date(dateArray[0], dateArray[1]-1, dateArray[2])
//   return {date, value}
// })
var data = JSON.parse(json data here).map(({date, value}) => {
  const dateArray = date.split('-');
  date = new Date(dateArray[0], dateArray[1]-1, dateArray[2])
  return {date, value}
});
var height = 500;
var width = 960;
var margin = ({top: 20, right: 30, bottom: 30, left: 40});
var x = d3.scaleTime()
    .domain(d3.extent(data, d => d.date))
    .range([margin.left, width - margin.right]);
var y = d3.scaleLinear()
    .domain([0, d3.max(data, d => d.value)]).nice()
    .range([height - margin.bottom, margin.top]);
var xAxis = g => g
    .attr("transform", `translate(0,${height - margin.bottom})`)
    .call(d3.axisBottom(x).ticks(width / 80).tickSizeOuter(0));
var yAxis = g => g
    .attr("transform", `translate(${margin.left},0)`)
    .call(d3.axisLeft(y).ticks(8, "$.0f"))
    .call(g => g.select(".domain").remove())
    .call(g => g.select(".tick:last-of-type text").clone()
        .attr("x", 3)
        .attr("text-anchor", "start")
        .attr("font-weight", "bold")
        .text(data.y))
var line = d3.line()
    .defined(d => !isNaN(d.value))
    .x(d => x(d.date))
    .y(d => y(d.value));




(function chart (){
  var svg = d3.select("svg");
  debugger
  svg.append("g")
      .call(xAxis);

  svg.append("g")
      .call(yAxis);

  svg.append("path")
      .datum(data)
      .attr("fill", "none")
      .attr("stroke", "steelblue")
      .attr("stroke-width", 1.5)
      .attr("stroke-linejoin", "round")
      .attr("stroke-linecap", "round")
      .attr("d", line);

  return svg.node();
})();

