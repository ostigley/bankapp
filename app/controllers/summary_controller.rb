# frozen_string_literal: true

class SummaryController < ApplicationController
  before_action :categories

  def index
    @transactions = Transaction.all
    @transactions_30_days = Transaction.where(transaction_date: (Time.now.to_date - 30.days)..Time.now.to_date)
    @transactions_3_months = Transaction.where(transaction_date: (Time.now.to_date - 3.months)..Time.now.to_date)
  end

  def show
    start_date = Date.new(date_range_params[:year].to_i, date_range_params[:month].to_i)
    end_date = start_date.end_of_month
    @transactions = Transaction.where(transaction_date: start_date..end_date)
  end

  private

  def categories
    @categories = CategoryDetail.all.map(&:category).uniq
  end

  def date_range_params
    params.permit(:month, :year)
  end
end