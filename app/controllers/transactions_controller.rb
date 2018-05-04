# frozen_string_literal: true

class TransactionsController < ApplicationController
  include FileConverter

  def new
  end

  def create
    @file = tranaction_params
    save_entries
  end

  private

  def tranaction_params
    params.require(:file)
  end
end
