# frozen_string_literal: true

module Transactions
  class FromCsv
    require 'csv'
    attr_reader :transactions

    def self.import(csv_file)
      @transactions = []
      @csv = CSV.parse(csv_file.read, headers: true)

      @csv.each do |row|
        transaction_hash = convert_hash_keys(row.to_hash)
        @transactions << CreateTransaction.new(transaction_hash).create!
      end

      @transactions
    end

    def self.convert_hash_keys(hash)
      Hash[hash.map { |k, v| [k.to_s.underscore.to_sym, v] }]
    end
  end
end
