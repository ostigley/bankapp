# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true
  validate :fields_are_parameterized

  def fields_are_parameterized
    parameterized?(detail)
    parameterized?(category)
  end
end
