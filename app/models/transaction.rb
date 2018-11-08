# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true

  scope :find_category_date, ->(params) {
    category = params[:category]
    start_date = params[:date].to_date
    end_date = params[:date].to_date + 1.month - 1.day
    where(category: category, transaction_date: start_date..end_date).order(transaction_date: :asc)
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
