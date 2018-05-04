# frozen_string_literal: true

class TransactionsController < ApplicationController
  include FileConverter

  def new
  end

  def upload
    @file = file_params
    @transactions = save_entries
    generate_categories
    redirect_to action: 'bulk_edit', ids: @transactions.map(&:id)
  end

  def bulk_edit
    @transactions = Transaction.find(ids).select {|t| t.category.blank? }
    @category_details = CategoryDetail.all
    render :edit
  end

  def update
    respond_to do |format|
      format.json  do
        @transaction = Transaction.find_by_id(transaction_params[:id])
        @category_detail = CategoryDetail.find_or_create_by!(detail: transaction_params[:detail]) do |cd|
          cd.category = transaction_params[:category]
        end

        @transaction.category = @category_detail.category
        if @transaction.save!
          return head :ok
        end
      end
    end

  rescue
    binding.pry
  end

  private

  def file_params
    params.require(:file)
  end

  def transaction_params
    params.require(:transaction).permit(:id, :detail, :category)
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
