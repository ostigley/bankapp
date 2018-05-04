# frozen_string_literal: true

class TransactionsController < ApplicationController
  include FileConverter

  def new
  end

  def upload
    @file = tranaction_params
    @transactions = save_entries
    redirect_to action: 'bulk_edit', ids: @transactions.map(&:id)
  end

  def bulk_edit
    @transactions = Transaction.find(ids)

    render :edit
  end

  private

  def tranaction_params
    params.require(:file)
  end

  def ids
    params[:ids].split '/'
  end
end
