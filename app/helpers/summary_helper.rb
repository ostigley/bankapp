# frozen_string_literal: true

module SummaryHelper
  def income
    @income ||= sum_category('income')
  end

  def sum_category(category)
    @transactions.select { |transaction| transaction.category == category }.sum(&:amount).round.abs
  end

  def percent(a, b)
    number_to_percentage(a.to_f/b.to_f*100, precision: 0)
  end
end
