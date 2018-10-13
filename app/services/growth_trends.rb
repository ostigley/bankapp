# frozen_string_literal: true

class GrowthTrends
  attr_reader :monthly_expenditure, :monthly_sum_all, :monthly_growth_all

  def initialize
    @month_ranges        = generate_month_ranges

    @monthly_expenditure = nil
    @monthly_sum_all     = nil
    @monthly_growth_all  = nil
  end

  def generate
    @monthly_expenditure = generate_monthly_expenditure
    @monthly_sum_all     = generate_monthly_sum_all
    @monthly_growth_all  = generate_monthly_growth_all

    self
  end

  private

  def generate_month_ranges
    result = []
    # Create an arrah of month ranges, for the last two years
    24.times do |n|
      month = Time.zone.now.to_date - (n).month
      first_day = month - month.day + 1.day
      last_day = first_day + 1.month - 1.day
      range = first_day..last_day
      result << range
    end

    result.reverse!
  end

  def generate_monthly_expenditure
    # total outgoings (sum amounts excluding shares and income)
    @month_ranges.map do |month_range|
      {
        date:  month_range.first.strftime('%Y-%m-%d'),
        value: Transaction.where(transaction_date: month_range).where.not(category: 'income').where.not(category: 'shares').sum(:amount)
      }
    end
  end

  def generate_monthly_sum_all
    # Generate an array of month ranges with total transactions for those ranges
    @month_ranges.map do |month_range|
      {
        date:  month_range.first.strftime('%Y-%m-%d'),
        value: Transaction.where(transaction_date: month_range).sum(:amount)
      }
    end
  end

  def generate_monthly_growth_all
    # Calculate growth from month on month (return array of values for each month)
    # ie integrate
    @monthly_sum_all.each_with_index.map do |date_value_hash, i|
      {
        date: date_value_hash[:date],
        value: @monthly_sum_all[0..i].reduce(0) { |current_value, date_range_transaction| current_value + date_range_transaction[:value] }
      }
    end
  end
end
