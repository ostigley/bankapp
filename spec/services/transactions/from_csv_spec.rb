# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transactions::FromCsv do
  describe '#import' do
    let(:csv) { fixture_file_upload('test_debit_card_negative_amounts.csv', 'text/csv') }
    let(:new_transactions) { Transactions::FromCsv.import(csv) }

    it 'returns an array of transactions' do
      new_transactions.each do |transaction|
        expect(transaction).to be_a Transaction
      end
    end
  end
end