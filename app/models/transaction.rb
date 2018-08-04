# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true

  scope :find_category_date, ->(params) {
    category = params[:category]
    start_date = params[:date].to_date
    end_date = params[:date].to_date + 1.month - 1.day
    where(category: category, transaction_date: start_date..end_date).order(transaction_date: :asc)
  }
end
