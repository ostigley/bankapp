module Transactions
  class CreateTransaction
    attr_reader :transaction_hash

    def initialize(transaction_hash)
      @transaction_hash = transaction_hash
    end

    def create!
    # create object and save
    end

    # def credit_card_transaction?
    #   card = transaction_hash[:card]
    #   # 4988-****-****-9318
    #   card.present && card ~= /[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/
    # end

    # def transaction_detail
    #   credit_card_transaction? ? cc_transaction_detail : dc_transaction_detail
    # end

    # def cc_transaction_detail
    #   transaction_hash[:details]
    # end

    # def dc_transaction_detail
    #   dc_transcation_type2? ? transaction_hash[:code] : transaction_hash[:details]
    # end

    # def dc_transaction_type2?
    #   transaction_hash[:details] ~= /[0-9]{4}-(\*{4}-\*{4})-[0-9]{4}/
    # end
  end
end