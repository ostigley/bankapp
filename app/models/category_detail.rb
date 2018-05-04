class CategoryDetail < ApplicationRecord
  validates :detail, uniqueness: true
end