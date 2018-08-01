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
    start_date = transactions.first.transaction_date
    category_months = transactions.each_with_object(months_object({}, start_date)) do |tx, obj|
      month_year = tx.transaction_date.strftime('%b, %Y')
      obj[month_year] += tx.amount.round.abs
    end

    @tsv = HashToTsv.new(category_months, 'month\tvalue').tsv
    render :category
  end

  def category_month
    category = params[:category]
    start_date = params[:date].to_date
    end_date = params[:date].to_date + 1.month - 1.day
    @transactions = Transaction.where(category: category, transaction_date: start_date..end_date).order(transaction_date: :asc)

    @transactions = @transactions.each_with_object(days_object({}, start_date)) do |tx, obj|
      day = tx.transaction_date.strftime('%A %d')
      obj[day] << tx
    end

    render :category_month
  end

  private

  def tsv_header
    ['Month\tYear']
  end

  def categories
    @categories = CategoryDetail.all.map(&:category).uniq
  end

  def date_range_params
    params.permit(:month, :year)
  end

  def months_object(current_hash, date)
    next_date = date.strftime('%b, %Y')
    current_hash[next_date] = 0

    return current_hash if next_date == Time.zone.now.strftime('%b, %Y')

    months_object(current_hash, date + 1.month)
  end

  def days_object(current_hash, date)
    next_date = date.strftime('%A %d')
    current_hash[next_date] = []

    return current_hash if next_date == Time.zone.now.strftime('%A %d')

    days_object(current_hash, date + 1.day)
  end
end