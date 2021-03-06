# frozen_string_literal: true

module SummaryHelper
  def category_percent(category, transactions)
    income = sum_category('income', transactions)
    return '-' if income.zero?
    total = sum_category(category, transactions)
    number_to_percentage(total.to_f / income.to_f * 100, precision: 0)
  end

  def sum_category(category, transactions)
    transactions.select { |transaction| transaction.category == category }.sum(&:amount).round.abs
  end

  def percent(a, b)
    number_to_percentage(a.to_f / b.to_f * 100, precision: 0)
  end

  def percentage_days_remaining
    Time.zone.now.end_of_month.day.to_f / Time.zone.now.day.to_f
  end
end
