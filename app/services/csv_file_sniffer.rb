# frozen_string_literal: true

class CsvFileSniffer
  def initialize(csv)
    @csv
    @headers = csv.headers
  end

  def calculate_date_header
    date_headers = @headers.select { |h| h.match(/date/i) }
    return underscore_key(date_headers.first) if date_headers.count == 1

    # return date header that has 'transaction' key word
    transaction_date_header = date_headers.detect { |t| t.match(/transaction/i) }
    underscore_key(transaction_date_header)
  end

  def calculate_amount_header
    # place holder if other csv files have different headers
    :amount
  end

  def calculate_detail_headers
    detail_headers = []

    @headers.each do |header|
      detail_headers << underscore_key(header) unless header =~ /amount|date|currency/i
    end

    detail_headers
  end

  def credit_card?
    @headers.include?('ProcessedDate')
  end

  private

  def underscore_key(key)
    key.to_s.underscore.to_sym
  end

  def convert_hash_keys(hash)
    Hash[hash.map { |k, v| [underscore_key(k), v] }]
  end
end
