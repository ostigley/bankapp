module TransactionsFileConverter
  extend ActiveSupport::Concern
  require 'csv'

  def create_all_transactions
    @transactions = []
    csv_text = @file.read
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      h = convert_hash_keys(row.to_hash)
      date = h[:transaction_date].present? ? h[:transaction_date] : h[:date]

      @transactions << Transaction.create!({
        transaction_date: date,
        detail: h[:details],
        amount: h[:amount]
      })
    end

    @transactions
  end

  private

  def underscore_key(k)
    k.to_s.underscore.to_sym
  end

  def convert_hash_keys(h)
    Hash[h.map { |k, v| [underscore_key(k), v] }]
  end
end
