# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true
  default_scope { where("transaction_date > ?", Date.new(2020,11,21)) }
  scope :sum_month_category, ->(category, date) {
    where(category: category, transaction_date: date.beginning_of_month...date.end_of_month).sum(:amount)
  }

  scope :find_category_date, ->(params) {
    category = params[:category]
    start_date = params[:date].to_date
    end_date = params[:date].to_date + 1.month - 1.day
    where(category: category, transaction_date: start_date..end_date).order(transaction_date: :asc)
  }

  scope :category_to_day_in_month, ->(category, day) {
    where(category: category).select do |transaction|
      transaction.transaction_date.day <= day
    end
  }

  def self.last_30_days
    where(transaction_date: (Time.zone.now.to_date - 30.days)..Time.zone.now.to_date)
  end

  def self.last_3_months
    where(transaction_date: (Time.zone.now.to_date - 3.months)..Time.zone.now.to_date)
  end

  def self.last_12_months
    where(transaction_date: (Time.zone.now.to_date - 12.months)..Time.zone.now.to_date)
  end

  def self.current_month
    where(transaction_date: (Time.zone.now.beginning_of_month.to_date)..Time.zone.now.to_date)
  end
end
