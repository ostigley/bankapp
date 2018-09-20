# frozen_string_literal: true

module Transactions
  class CreateTransaction
    attr_reader :transaction_hash

    def initialize(transaction_hash)
      @transaction_hash = transaction_hash
    end

    def create!
      Transaction.find_or_create_by(transaction_hash: tx_hash) do |transaction|
        transaction.transaction_date = transaction_date
        transaction.detail           = transaction_detail
        transaction.amount           = transaction_hash[:amount]
        transaction.transaction_hash = tx_hash
      end
    end

    def credit_card_transaction?
      card = transaction_hash[:card]
      # 4988-****-****-9318
      card.present? && card.match(/[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/).present?
    end

    def transaction_detail
      credit_card_transaction? ? cc_transaction_detail : dc_transaction_detail
    end

    def transaction_date
      credit_card_transaction? ? transaction_hash[:transaction_date] : transaction_hash[:date]
    end

    def cc_transaction_detail
      transaction_hash[:details].gsub(/\s+/, ' ')
    end

    def dc_transaction_detail
      detail = dc_transaction_type2? ? transaction_hash[:code] : transaction_hash[:details]
      detail.gsub(/\s+/, ' ')
    end

    def dc_transaction_type2?
      transaction_hash[:details].match(/[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/).present?
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
