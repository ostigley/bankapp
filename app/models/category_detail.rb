# frozen_string_literal: true

class CategoryDetail < ApplicationRecord
  validates :detail, uniqueness: true
end
