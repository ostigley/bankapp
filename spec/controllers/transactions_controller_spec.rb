# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do
  describe 'new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'upload' do
    context 'for debit card csv files' do
      before do
        @positive_debit_card_file = fixture_file_upload('test_debit_card_positive_amounts.csv', 'text/csv')
        @negative_debit_card_file = fixture_file_upload('test_debit_card_negative_amounts.csv', 'text/csv')
      end

      it 'assigns an array of transactions' do
        post :upload, params: { file: @positive_debit_card_file }
        assigns[:transactions].each do |transaction|
          expect(transaction).to be_a Transaction
        end
      end

      it 'adds debits as negative values' do
        post :upload, params: { file: @negative_debit_card_file }
        expect(Transaction.last.amount).to be < 0
      end

      it 'adds credits as positve values' do
        post :upload, params: { file: @positive_debit_card_file }
        expect(Transaction.first.amount).to be > 0
      end

      it 'adds category Income if amount is credit or positive' do
        post :upload, params: { file: @positive_debit_card_file }
        expect(Transaction.first.category).to eq 'Income'
      end

      it 'imports transactions to the database' do
        expect(Transaction.count).to eq 0
        post :upload, params: { file: @positive_debit_card_file }

        expect(Transaction.count).to be > 0
      end

      context 'with category details already in the database' do
        before do
          category_detail = instance_double('CategoryDetail', category: 'test category')
          allow(CategoryDetail).to receive(:find_by).and_return(category_detail)
        end

        it 'finds the category_detail and adds it to the transaction' do
          post :upload, params: { file: @negative_debit_card_file }
          Transaction.all.each do |transaction|
            expect(transaction.category).to eq 'test category'
          end
        end
      end

      context 'with no category details already in the database' do
        it 'sets category_detail to nil for the transaction' do
          post :upload, params: { file: @negative_debit_card_file }
          Transaction.all.each do |transaction|
            expect(transaction.category).to be nil
          end
        end
      end
    end

    context 'for credit card csv files' do
      before do
        @positive_credit_card_file = fixture_file_upload('test_credit_card_positive_amounts.csv', 'text/csv')
        @negative_credit_card_file = fixture_file_upload('test_credit_card_negative_amounts.csv', 'text/csv')
      end

      it 'adds debits as negative values' do
        post :upload, params: { file: @negative_credit_card_file }
        expect(Transaction.last.amount).to be < 0
      end

      it 'adds credits as positve values' do
        post :upload, params: { file: @positive_credit_card_file }
        expect(Transaction.first.amount).to be > 0
      end

      it 'assigns an array of transactions' do
        post :upload, params: { file: @negative_credit_card_file }
        assigns[:transactions].each do |transaction|
          expect(transaction).to be_a Transaction
        end
      end

      it 'imports transactions to the database' do
        expect(Transaction.count).to eq 0
        post :upload, params: { file: @negative_credit_card_file }

        expect(Transaction.count).to be > 0
      end

      context 'with category details already in the database' do
        before do
          category_detail = instance_double('CategoryDetail', category: 'test category')
          allow(CategoryDetail).to receive(:find_by).and_return(category_detail)
        end

        it 'finds the category_detail and adds it to the transaction' do
          post :upload, params: { file: @negative_credit_card_file }
          Transaction.all.each do |transaction|
            expect(transaction.category).to eq 'test category'
          end
        end
      end

      context 'with no category details already in the database' do
        it 'sets category_detail to nil for the transaction' do
          post :upload, params: { file: @negative_credit_card_file }
          Transaction.all.each do |transaction|
            expect(transaction.category).to be nil
          end
        end
      end
    end
  end
end
