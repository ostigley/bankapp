# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    date 2.days.ago
    detail 'MacDonalds'
    category nil

    trait :positive do
      amount 100.00
    end

    trait :negative do
      amount 0 - 100.00
    end
  end
end
