# frozen_string_literal: true

require 'rails_helper'
require 'csv'

RSpec.describe CsvTransform do
  describe 'calculate_date_header' do
    context 'credit card csv file' do
      let(:csv) { CSV.read(Rails.root.join('spec', 'fixtures', 'test_credit_card_negative_amounts.csv'), headers: true) }
      let(:csv_tranform_instance) { CsvTransform.new(csv) }

      it 'returns the hash key containing the transaction date' do
        expect(csv_tranform_instance.calculate_date_header).to eq :transaction_date
      end
    end

    context 'debit card csv file' do
      let(:csv) { CSV.read(Rails.root.join('spec', 'fixtures', 'test_debit_card_negative_amounts.csv'), headers: true) }
      let(:csv_tranform_instance) { CsvTransform.new(csv) }

      it 'returns the hash key containing the transaction date' do
        expect(csv_tranform_instance.calculate_date_header).to eq :date
      end
    end
  end
end