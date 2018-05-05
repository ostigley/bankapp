# frozen_string_literal: true

class CategoryDetail < ApplicationRecord
  validates :detail, uniqueness: true
  validate :fields_are_parameterized

  def fields_are_parameterized
    parameterized?(detail)
    parameterized?(category)
  end
end
