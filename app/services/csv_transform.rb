class CsvTransform
  def initialize(csv)
    @csv = csv
  end

  def calculate_date_header
    headers = @csv.headers
    date_headers = headers.select { |h| h.match(/date/i) }
    return underscore_key(date_headers.first) if date_headers.count == 1

    # return date header that has 'transaction' key word
    transaction_date_header = date_headers.detect { |t| t.match(/transaction/i) }
    underscore_key(transaction_date_header)
  end

  private

  def underscore_key(k)
    k.to_s.underscore.to_sym
  end

  def convert_hash_keys(h)
    Hash[h.map { |k, v| [underscore_key(k), v] }]
  end
end