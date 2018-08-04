# frozen_string_literal: true

class SummaryController < ApplicationController
  before_action :categories, except: :category

  def index
    @transactions = Transaction.all
    @transactions_30_days = Transaction.last_30_days
    @transactions_3_months = Transaction.last_3_months
  end

  def show
    start_date = Date.new(params[:year].to_i, params[:month].to_i)
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
end
