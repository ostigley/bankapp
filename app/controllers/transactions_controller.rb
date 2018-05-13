# frozen_string_literal: true

class TransactionsController < ApplicationController
  include TransactionsFromFile
  include CategoryDetailLookup

  before_action :all_categories, only: :bulk_edit

  def new; end

  def upload
    @file = file_params
    @transactions = create_all_transactions
    add_category_to_transactions

    redirect_to action: 'bulk_edit', ids: @transactions.map(&:id)
  end

  def bulk_edit
    @transactions = Transaction.where(category: nil).sort do |a,b|
      a_count = Transaction.where(category: nil, detail: a.detail).count
      b_count = Transaction.where(category: nil, detail: b.detail).count
      b_count <=> a_count
    end
    render :edit
  end

  def update
    respond_to do |format|
      format.json do
        return head :ok if update_transactions
      end
    end
  rescue StandardError => e
    render status: :internal_server_error, body: e
  end

  private

  def file_params
    params.require(:file)
  end

  def transaction_params
    params.require(:transactions).permit(:detail, :category, ids: [])
  end

  def update_transactions
    transaction_params[:ids].each do |id|
      @transaction = Transaction.find_by(id: id)

      @transaction.category = if transaction_params[:detail]
                                find_or_create_category_detail(transaction_params)
                              else
                                transaction_params[:category]
                              end
      @transaction.save!
    end
  end
end
