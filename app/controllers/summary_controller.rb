# frozen_string_literal: true

class SummaryController < ApplicationController
  before_action :categories, except: :category

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

  def category
    transactions = Transaction.where(category: params[:category]).order(transaction_date: :asc)
    transactions_per_month_hash = Transactions::DateReduce.by_month(transactions)
    @tsv = HashToTsv.convert(transactions_per_month_hash, 'month\tvalue')

    render :category
  end

  def category_month
    @transactions = Transactions::DateReduce.by_day Transaction.find_category_date(params)

    render :category_month
  end

  private

  def categories
    @categories = CategoryDetail.all.map(&:category).uniq
  end

  def date_range_params
    params.permit(:month, :year)
  end

  # def days_object(current_hash, date)
  #   next_date = date.strftime('%A %d')
  #   current_hash[next_date] = []

  #   return current_hash if next_date == Time.zone.now.strftime('%A %d')

  #   days_object(current_hash, date + 1.day)
  # end
end