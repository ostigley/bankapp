# frozen_string_literal: true

module TransactionsFileConverter
  extend ActiveSupport::Concern
  require 'csv'

  def create_all_transactions
    @transactions = []
    csv_text = @file.read
    csv = CSV.parse(csv_text, headers: true)

    credit_card?(csv)

    csv.each do |row|
      transaction_hash = convert_hash_keys(row.to_hash)

      @transactions << Transaction.create!(
        transaction_date: get_date(transaction_hash),
        amount:           get_amount(transaction_hash),
        detail:           transaction_hash[:details].parameterize
      )
    end

    @transactions
  end

  private

  def get_date(transaction_hash)
    @is_credit_card ? transaction_hash[:transaction_date] : transaction_hash[:date]
  end

  def get_amount(transaction_hash)
    return transaction_hash[:amount] unless @is_credit_card

    if transaction_hash[:type] == 'D'
      0 - transaction_hash[:amount].to_f
    else
      transaction_hash[:amount]
    end
  end

  def underscore_key(k)
    k.to_s.underscore.to_sym
  end

  def credit_card?(csv)
    @is_credit_card ||= csv.headers.include?('Card')
  end

  def convert_hash_keys(h)
    Hash[h.map { |k, v| [underscore_key(k), v] }]
  end
end
