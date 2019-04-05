# frozen_string_literal: true

class AnalyseTrends
  # analyse trend from last 12 months
  def initialize(growth_trends)
    @monthly_expenditure = growth_trends.monthly_expenditure.last(12)
    @average_expenditure = @monthly_expenditure.reduce(0) do |current_value, date_range_transaction|
      current_value + date_range_transaction[:value]
    end / 12
  end
end
