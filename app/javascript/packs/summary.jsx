import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import LineGraph from './graphs/lineGraph'
const Summary = props => {
  const {monthly_expenditure, monthly_sum_all, monthly_growth_all} = props;
  return(<div>
    <LineGraph chartName='Monthly Expenditure' data={monthly_expenditure} />
    <LineGraph chartName='Monthly Sum All' data={monthly_sum_all} />
    <LineGraph chartName='Monthly Growth All' data={monthly_growth_all} />
  </div>)
}

document.addEventListener('DOMContentLoaded', () => {
  const props = $('#props').data('props')
  ReactDOM.render(
    <Summary {...props} />,
    document.body.appendChild(document.createElement('div')),
  )
})
