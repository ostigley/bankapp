# frozen_string_literal: true

module Transactions
  class CreateTransaction
    attr_reader :transaction_hash, :transaction_keys

    def initialize(transaction_hash)
      @transaction_hash = transaction_hash
      @transaction_keys = transaction_hash.keys
    end

    def create!
      Transaction.find_or_create_by(transaction_hash: tx_hash) do |transaction|
        transaction.transaction_date = transaction_date
        transaction.detail           = transaction_detail
        transaction.amount           = transaction_amount
        transaction.transaction_hash = tx_hash
      end
    end

    def credit_card_transaction?
      card = transaction_hash[:card]
      # 4988-****-****-9318
      card.present? && card.match(/[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/).present?
    end

    # def transaction_detail
    #   credit_card_transaction? ? cc_transaction_detail : dc_transaction_detail
    # end

    def transaction_date
      credit_card_transaction? ? transaction_hash[:transaction_date] : transaction_hash[:date]
    end

    # def cc_transaction_detail
    #   merged_details
    #   # transaction_hash[:details].gsub(/\s+/, ' ')
    # end

    # def dc_transaction_detail
    #   merged_details
    #   # detail = dc_transaction_type2? ? transaction_hash[:code] : transaction_hash[:details]
    #   # detail.gsub(/\s+/, ' ')
    # end

    def dc_transaction_type2?
      # These types of transactions have meaningless content in the detail section
      # so we check and use something else if that is the case.
      transaction_hash[:details].match(/[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/).present?
    end

    def detail_keys
      # skip keys that have these details to keep the detail simple
      transaction_keys.delete_if { |key| key.to_s =~ /amount|date|currency|reference/ }
    end

    def transaction_detail
      details = []
      detail_keys.each do |key|
        # next if has card details(****) or is blank
        next if transaction_hash[key].blank? || transaction_hash[key] =~ /[*]{4}/
        details << [key.capitalize, transaction_hash[key]].join(': ')
      end

      details.join(', ').gsub(/\s+/, ' ')
    end

    def tx_hash
      Digest::MD5.hexdigest transaction_hash.to_s
    end

    def transaction_amount
      return transaction_hash[:amount].to_f unless credit_card_transaction?

      if transaction_hash[:type] =~ /^D|Debit/
        0 - transaction_hash[:amount].to_f
      else
        transaction_hash[:amount].to_f
      end
    end
  end
end
