# frozen_string_literal: true

class Transaction < ApplicationRecord
  validates :transaction_date, :amount, :detail, presence: true
  validate :detail_is_parameterized

  def detail_is_parameterized
    return true unless detail.parameterize != detail

    errors.add(:detail, "Must be parameterized: #{detail}")
  end
end
