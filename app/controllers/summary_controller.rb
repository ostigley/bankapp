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
    transactions = Transaction.where(category: params[:category]).order(transaction_date: :desc)

    category_months = transactions.each_with_object({}) do |tx, obj|
      month_year = tx.transaction_date.strftime('%b')
      obj[month_year] = if obj.has_key? month_year
                          obj[month_year] + tx.amount.round.abs
                        else
                          tx.amount.round.abs
                        end
    end

    @tsv = HashToTsv.new(category_months, 'month\tvalue').tsv
    render :category
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
end