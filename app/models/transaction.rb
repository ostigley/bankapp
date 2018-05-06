# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true
end
