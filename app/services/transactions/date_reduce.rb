# frozen_string_literal: true

# Convert transactions to a hash of month keys and amount values for transactions
module Transactions
  class DateReduce
    include DateHash

    def self.by_month(date_sorted_transactions)
      start_date = date_sorted_transactions.first.transaction_date
      months_object = DateHash.months(start_date)

      date_sorted_transactions.each_with_object(months_object) do |tx, obj|
        month_year = tx.transaction_date.strftime('%b, %Y')
        obj[month_year] += tx.amount.round.abs
      end
    end

    def self.by_day(date_sorted_transactions)
      start_date = date_sorted_transactions.first.transaction_date
      days_object = DateHash.days(start_date)

      date_sorted_transactions.each_with_object(days_object) do |tx, obj|
        day = tx.transaction_date.strftime('%A %d')
        obj[day] << tx
      end
    end
  end
end
