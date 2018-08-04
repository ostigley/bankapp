# frozen_string_literal: true

# Convert transactions to a hash of month keys and amount values for transactions
module Transactions
  class MonthReduce
    include DateHash

    def self.reduce(date_sorted_transactions)
      start_date = date_sorted_transactions.first.transaction_date
      months_object = DateHash.months(start_date)

      date_sorted_transactions.each_with_object(months_object) do |tx, obj|
        month_year = tx.transaction_date.strftime('%b, %Y')
        obj[month_year] += tx.amount.round.abs
      end
    end
  end
end

