import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import * as d3 from "d3";

export default class LineGraph extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    // D3
    const data = this.props.data.map(({date, value}) => {
      const dateArray = date.split('-');
      date = new Date(dateArray[0], dateArray[1]-1, dateArray[2])
      return {date, value}
    });
    const height = 500;
    const width = 960;
    const margin = ({top: 20, right: 30, bottom: 30, left: 40});
    const x = d3.scaleTime()
    .domain(d3.extent(data, d => d.date))
    .range([margin.left, width - margin.right]);
    const y = d3.scaleLinear()
    .domain([d3.min(data, d => d.value), d3.max(data, d => d.value)]).nice()
    .range([height - margin.bottom, margin.top]);
    const xAxis = g => g
    .attr("transform", `translate(0,${y(0)})`)
    .call(d3.axisBottom(x).ticks(width / 24).tickSizeOuter(0));
    const yAxis = g => g
    .attr("transform", `translate(${margin.left},0)`)
    .call(d3.axisLeft(y).ticks(8, "$.0f"))
    .call(g => g.select(".domain").remove())
    .call(g => g.select(".tick:last-of-type text").clone()
      .attr("x", 3)
      .attr("text-anchor", "start")
      .attr("font-weight", "bold")
      .text(data.y))
    const line = d3.line()
    .defined(d => !isNaN(d.value))
    .x(d => x(d.date))
    .y(d => y(d.value));
    var svg = d3.select(`#svg_${this.props.chartName.replace(/\s/g,'-')}`)

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

    svg.node();
  }

  render() {
    const { chartName,
    } = this.props;

    return (
      <div>
        <h2>{this.props.chartName}</h2>
        <p>{this.props.description}</p>
        <svg height="500" width="960" id={`svg_${chartName.replace(/\s/g,'-')}`}></svg>
      </div>
    );
  }
}

// LineGraph.propTypes = {
//   chartName: PropTypes.string,
//   data: propTypes.object
// }
