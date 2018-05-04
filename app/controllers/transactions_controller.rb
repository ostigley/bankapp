# frozen_string_literal: true

class TransactionsController < ApplicationController
  include FileConverter

  def new
  end

  def upload
    @file = tranaction_params
    @transactions = save_entries
    generate_categories
    redirect_to action: 'bulk_edit', ids: @transactions.map(&:id)
  end

  def bulk_edit
    @transactions = Transaction.find(ids).select {|t| t.category.blank? }
    @category_details = CategoryDetail.all
    render :edit
  end

  def bulk_update

  end

  private

  def tranaction_params
    params.require(:file)
  end

  def ids
    params[:ids].split '/'
  end

  def generate_categories
    @transactions.each do |transaction|
      category = CategoryDetail.find_by(detail: transaction.detail)
      transaction.update_attribute(:category, category&.category)
    end
  end
end
