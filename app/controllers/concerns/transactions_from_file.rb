# frozen_string_literal: true

module TransactionsFromFile
  extend ActiveSupport::Concern
  require 'csv'

  def create_all_transactions
    @transactions = []
    csv_text = @file.read
    csv = CSV.parse(csv_text, headers: true)

    @csv_sniffer = CsvFileSniffer.new(csv)

    csv.each do |row|
      transaction_hash = convert_hash_keys(row.to_hash)

      @transactions << Transaction.create!(
        transaction_date: get_date(transaction_hash),
        amount:           get_amount(transaction_hash),
        detail:           get_detail(transaction_hash)
      )
    end

    @transactions
  end

  private

  def get_detail(transaction_hash)
    detail = []
    @csv_sniffer.calculate_detail_headers.each do |header|
      # next if has card details(****) or is blank
      next if transaction_hash[header].blank? || transaction_hash[header] =~ /[*]{4}/ || header == :reference

      detail << [header.capitalize, transaction_hash[header]].join(': ')
    end

    strip_extra_whitespace(detail.join(', '))
  end

  def get_date(transaction_hash)
    transaction_hash[@csv_sniffer.calculate_date_header]
  end

  def get_amount(transaction_hash)
    amount_header = @csv_sniffer.calculate_amount_header
    return transaction_hash[amount_header] unless @csv_sniffer.credit_card?

    if transaction_hash[:type] =~ /^D|Debit/
      0 - transaction_hash[amount_header].to_f
    else
      transaction_hash[amount_header]
    end
  end

  def strip_extra_whitespace(str)
    str.gsub(/\s{2,}/, ' ')
  end

  def underscore_key(key)
    key.to_s.underscore.to_sym
  end

  def convert_hash_keys(hash)
    Hash[hash.map { |k, v| [underscore_key(k), v] }]
  end
end