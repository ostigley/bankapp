# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::CreateTransaction do
  let(:credit_card_transaction_hash) do
    {
      card: '4988-****-****-9318',
      type: 'D',
      amount: '12.95',
      details: 'Eat My Lunch           Mount Eden    Nz ',
      transaction_date: '03/08/2018',
      processed_date: '03/08/2018',
      foreign_currency_amount: nil,
      conversion_charge: nil
    }
  end
  context 'credit card' do
    let(:new_transaction) { Transactions::CreateTransaction.new(credit_card_transaction_hash) }

    describe '#new' do
      it 'initialises the transaction_hash attribute' do
        expect(new_transaction.transaction_hash).to eq credit_card_transaction_hash
      end
    end

    describe '#credit_card_transaction?' do
      it 'returns true for a credit card transaction' do
        expect(new_transaction.credit_card_transaction?).to be true
      end
    end

    describe '#transaction_detail' do
      it 'returns the transaction detail' do
        expect(new_transaction.transaction_detail).to eq credit_card_transaction_hash[:details]
      end
    end

    describe '#cc_transaction_detail' do
      it 'returns the transaction detail' do
        expect(new_transaction.cc_transaction_detail).to eq credit_card_transaction_hash[:details]
      end
    end

    describe '#transaction_date' do
      it 'returns the transaction date' do
        expect(new_transaction.transaction_date).to eq credit_card_transaction_hash[:transaction_date]
      end
    end

    describe '#transaction_hash' do
      it 'generates a hash of the transaction' do
        expect(new_transaction.tranaction_hash).to_not be nil
      end
    end

    describe '#create!' do
      context 'unique transaction' do
        it 'adds the transaction to the database' do
          expect(new_transaction.create!).to change(Transaction.count).by(1)
        end

        it 'returns a Transaction object' do
          expect(new_transaction.create!).to be_a Transaction
        end
      end

      context 'repeat transaction' do
        before do
          new_transaction.create!
        end

        it 'does not add the transaction to the database' do
          expect(new_transaction.create!).to_not change(Transaction.count)
        end

        it 'returns the previous Transaction object' do
          expect(new_transaction.create!).to be_a Transaction
        end
      end
    end
  end
end
