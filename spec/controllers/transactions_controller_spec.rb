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

      it 'imports transactions to the database' do
        expect(Transaction.count).to eq 0
        post :upload, params: { file: @positive_debit_card_file }

        expect(Transaction.count).to be > 0
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

      it 'parameterizes transaction details' do
        post :upload, params: { file: @positive_debit_card_file }

        expect(Transaction.last.detail).to eq 'Taste Of India'.parameterize
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

      it 'imports transactions to the database' do
        expect(Transaction.count).to eq 0
        post :upload, params: { file: @negative_credit_card_file }

        expect(Transaction.count).to be > 0
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


      it 'parameterizes transaction details' do
        post :upload, params: { file: @positive_credit_card_file }

        expect(Transaction.last.detail).to eq 'Coffee Supreme Limited Wellington NZ'.parameterize
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

  describe 'bulk_edit' do
    let(:transactions) { create_list(:transaction, 3) }
    let!(:category_detail) { create(:category_detail) }

    before do
      get :bulk_edit, params: { ids: transactions.map(&:id) }
    end

    it 'assigns @transactions from ids in params' do
      expect(assigns[:transactions]).to eq transactions
    end

    it 'assigns @category_details' do
      expect(assigns[:category_details]).to eq CategoryDetail.all
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end

    context 'transactions that already have categories assigned' do
      let(:transaction_with_category) { create(:transaction, category: 'eating-out') }
      let(:transaction_without_category) { create(:transaction) }

      before do
        get :bulk_edit, params: { ids: [transaction_with_category.id, transaction_without_category.id] }
      end

      it 'only assigns @transactions that have no category' do
        expect(assigns[:transactions].include?(transaction_with_category)).to be false
        expect(assigns[:transactions].include?(transaction_without_category)).to be true
      end
    end
  end

  describe 'bulk_update' do
    before do
      @positive_debit_card_file = fixture_file_upload('test_debit_card_positive_amounts.csv', 'text/csv')
      @negative_debit_card_file = fixture_file_upload('test_debit_card_negative_amounts.csv', 'text/csv')
    end
  end
end
