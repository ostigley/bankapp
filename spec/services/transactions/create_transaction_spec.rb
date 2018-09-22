# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::CreateTransaction do
  let(:credit_card_transaction_hash) do
    {
      card: '1234-****-****-1234',
      type: 'D',
      amount: '4.00',
      details: 'Coffee Supreme Limited Wellington    Nz ',
      transaction_date: '01/05/2018',
      processed_date: '02/05/2018',
      foreign_currency_amount: nil,
      conversion_charge: nil
    }
  end

  let(:debit_card_transaction_hash_type1) do
    {
      type: 'Eft-Pos',
      details: 'Taste Of India',
      particulars: '1234********',
      code: '9318   C',
      reference: '111111111111',
      amount: '-11.11',
      date: '30/04/2018',
      foreign_currency_amount: nil,
      conversion_charge: nil
    }
  end

  let(:debit_card_transaction_hash_type2) do
    # these transactions have a card number in the detail field
    {
      type: 'Visa Purchase',
      details: '1234-****-****-1234',
      particulars: nil,
      code: 'Uber   *Trip',
      reference: nil,
      amount: '-6.50',
      date: '23/07/2018',
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
        detail_no_whitespace = 'Type: D, Details: Coffee Supreme Limited Wellington Nz '
        expect(new_transaction.transaction_detail).to eq detail_no_whitespace
      end
    end

    describe '#cc_transaction_detail' do
      it 'returns the transaction detail' do
        detail_no_whitespace = 'Type: D, Details: Coffee Supreme Limited Wellington Nz '
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
          expect(new_transaction.transaction_amount).to be < 0
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
    let(:new_transaction) { Transactions::CreateTransaction.new(debit_card_transaction_hash_type1) }

    describe '#new' do
      it 'initialises the transaction_hash attribute' do
        expect(new_transaction.transaction_hash).to eq debit_card_transaction_hash_type1
      end

      it 'initialises the transaction_keys attribute' do
        expect(new_transaction.transaction_keys).to eq debit_card_transaction_hash_type1.keys
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
          detail = 'Type: Eft-Pos, Details: Taste Of India, Code: 9318 C'
          expect(new_transaction.transaction_detail).to eq detail
        end
      end

      context 'type 2 transaction' do
        it 'returns the transaction code as the detail' do
          new_transaction = Transactions::CreateTransaction.new(debit_card_transaction_hash_type2)

          expect(new_transaction.transaction_detail).to eq 'Type: Visa Purchase, Code: Uber *Trip'
        end
      end
    end

    describe '#transaction_date' do
      it 'returns the transaction date' do
        expect(new_transaction.transaction_date).to eq debit_card_transaction_hash_type1[:date]
      end
    end

    describe '#tx_hash' do
      it 'generates a hash of the transaction' do
        expect(new_transaction.tx_hash).to_not be nil
      end
    end

    describe '#transaction_amount' do
      it 'returns the amount' do
        expect(new_transaction.transaction_amount).to eq(debit_card_transaction_hash_type1[:amount].to_f)
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
