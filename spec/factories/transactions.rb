# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    transaction_date 2.days.ago
    detail Faker::Company.name.parameterize
    category nil
    amount 0 - 100.00

    trait :positive do
      amount 100.00
    end
  end
end
