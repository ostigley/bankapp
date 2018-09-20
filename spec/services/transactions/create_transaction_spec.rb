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

  let(:debit_card_transaction_hash) do
    {
      type: 'Eft-Pos',
      details: 'Moore Wilson S',
      particulars: '4988********',
      code: '9318   C',
      reference: '180803171945',
      amount: '-64.95',
      date: '03/08/2018',
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
      it 'returns the transaction detail stripped of exra whitespace' do
        detail_no_whitespace = 'Eat My Lunch Mount Eden Nz '
        expect(new_transaction.transaction_detail).to eq detail_no_whitespace
      end
    end

    describe '#cc_transaction_detail' do
      it 'returns the transaction detail' do
        detail_no_whitespace = 'Eat My Lunch Mount Eden Nz '
        expect(new_transaction.cc_transaction_detail).to eq detail_no_whitespace
      end
    end

    describe '#transaction_date' do
      it 'returns the transaction date' do
        expect(new_transaction.transaction_date).to eq credit_card_transaction_hash[:transaction_date]
      end
    end

    describe '#tx_hash' do
      it 'generates a hash of the transaction' do
        expect(new_transaction.tx_hash).to_not be nil
      end
    end

    describe '#create!' do
      context 'unique transaction' do
        it 'adds the transaction to the database' do
          expect { new_transaction.create! }.to change { Transaction.count }.by(1)
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
          expect { new_transaction.create! }.to change { Transaction.count }.by(0)
        end

        it 'returns the previous Transaction object' do
          expect(new_transaction.create!).to be_a Transaction
        end
      end
    end

    describe '#transaction_amount' do
      context 'with type "D"' do
        it 'returns a negative amount' do
          expect(new_transaction.transaction_amount).to eq(0 - credit_card_transaction_hash[:amount].to_f)
        end
      end

      context 'with type "Debit"' do
        it 'returns a negative amount' do
          credit_card_transaction_hash[:type] = 'Debit'
          new_transaction = Transactions::CreateTransaction.new(credit_card_transaction_hash)
          expect(new_transaction.transaction_amount).to eq(0 - credit_card_transaction_hash[:amount].to_f)
        end
      end

      context 'with type "C"' do
        it 'returns a positive amount' do
          credit_card_transaction_hash[:type] = 'C'
          expect(new_transaction.transaction_amount).to eq credit_card_transaction_hash[:amount].to_f
        end
      end
    end
  end

  context 'debit card' do
    let(:new_transaction) { Transactions::CreateTransaction.new(debit_card_transaction_hash) }

    describe '#new' do
      it 'initialises the transaction_hash attribute' do
        expect(new_transaction.transaction_hash).to eq debit_card_transaction_hash
      end
    end

    describe '#credit_card_transaction?' do
      it 'returns false' do
        expect(new_transaction.credit_card_transaction?).to be false
      end
    end

    describe '#transaction_detail' do
      context 'type 1 transaction' do
        it 'returns the transaction detail' do
          expect(new_transaction.transaction_detail).to eq debit_card_transaction_hash[:details]
        end
      end

      context 'type 2 transaction' do
        it 'returns the transaction code as the detail' do
          type2_detail = '1232-****-****-1234'
          debit_card_transaction_hash[:details] = type2_detail
          new_transaction = Transactions::CreateTransaction.new(debit_card_transaction_hash)

          expect(new_transaction.transaction_detail).to eq '9318 C'
        end
      end
    end

    describe '#transaction_date' do
      it 'returns the transaction date' do
        expect(new_transaction.transaction_date).to eq debit_card_transaction_hash[:date]
      end
    end

    describe '#tx_hash' do
      it 'generates a hash of the transaction' do
        expect(new_transaction.tx_hash).to_not be nil
      end
    end

    describe '#transaction_amount' do
      it 'returns the amount' do
        expect(new_transaction.transaction_amount).to eq(debit_card_transaction_hash[:amount].to_f)
      end
    end

    describe '#create!' do
      context 'unique transaction' do
        it 'adds the transaction to the database' do
          expect { new_transaction.create! }.to change { Transaction.count }.by(1)
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
          expect { new_transaction.create! }.to change { Transaction.count }.by(0)
        end

        it 'returns the previous Transaction object' do
          expect(new_transaction.create!).to be_a Transaction
        end
      end
    end
  end
end
