var svg = d3.select("svg"),
    margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = +svg.attr("width") - margin.left - margin.right,
    height = +svg.attr("height") - margin.top - margin.bottom;

var x = d3.scaleBand().rangeRound([0, width]).padding(0.1),
    y = d3.scaleLinear().rangeRound([height, 0]);

var g = svg.append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");


var tsv = $('div[data-tsv]').data().tsv.split('\\t').join('\t').split('\\n').join('\n');

(function barGraph () {
  var data = d3.tsvParse(tsv)
  x.domain(data.map(function(d) { return d.month; }));
  y.domain([0, d3.max(data, function(d) { return Number(d.value); })*1.1]);

  g.append("g")
      .attr("class", "axis axis--x")
      .attr("transform", "translate(0," + height + ")")
      .call(d3.axisBottom(x));

  g.append("g").attr("class", "axis axis--y").call(d3.axisLeft(y).ticks(8))
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 15)
      .attr("dy", "1.7em")
      .attr("text-anchor", "end")
      .text("Value");

  g.selectAll(".bar")
    .data(data)
    .enter().append("rect")
      .attr("data-date", function(d) { return (d.month); })
      .attr("class", "bar")
      .attr("x", function(d) { return x(d.month); })
      .attr("y", function(d) { return y(Number(d.value)); })
      .attr("width", x.bandwidth())
      .attr("height", function(d) { return height - y(Number(d.value)); });

  $('rect').each(function(i,r) {
    $(r).on('click', () => {
      const date = $(r).data().date
      const category = window.location.pathname.split('/').pop();
      window.location.href = `/category_month/${category}/${date}`
    })
  })

})();