module FileConverter
  extend ActiveSupport::Concern
  require 'csv'

  def save_entries
    csv_text = @file.read
    csv = CSV.parse(csv_text, :headers => true)

    csv.each do |row|
      h = convert_hash_keys(row.to_hash)
      Transaction.create!({transaction_date: h[:transaction_date], detail: h[:details], amount: h[:amount]})
    end
  end

  private

  def underscore_key(k)
    k.to_s.underscore.to_sym
  end

  def convert_hash_keys(h)
    Hash[h.map { |k, v| [underscore_key(k), v] }]
  end
end
