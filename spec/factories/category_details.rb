# frozen_string_literal: true

FactoryBot.define do
  factory :category_detail do
    detail Faker::Company.name.parameterize
    category 'eating-out'
  end
end
