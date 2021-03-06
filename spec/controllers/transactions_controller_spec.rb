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

      it 'collates transaction details' do
        post :upload, params: { file: @positive_debit_card_file }
        detail = 'Type: Eft-Pos, Details: Taste Of India, Code: 9318 C'

        expect(Transaction.last.detail).to eq detail
      end

      context 'with category details already in the database' do
        before do
          category_detail = instance_double('CategoryDetail', category: 'test-category')
          allow(CategoryDetail).to receive(:find_by).and_return(category_detail)
        end

        it 'finds the category_detail and adds it to the transaction' do
          post :upload, params: { file: @negative_debit_card_file }
          Transaction.all.each do |transaction|
            expect(transaction.category).to eq 'test-category'
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

      context 'with transactions that have identical details but different reference' do
        before do
          @file = fixture_file_upload('test_debit_card_identical_detail_dif_reference.csv', 'text/csv')

          post :upload, params: { file: @file }
        end

        it 'are saved all with the same detail string' do
          # this has to happen to allow matching of transactions from the same establishment
          # at different times (ie different reference entries)

          details = Transaction.all.map(&:detail)
          expect(details.uniq.count).to eq 1
          expect(Transaction.count).to eq 4
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
        detail = 'Type: C, Details: Coffee Supreme Limited Wellington Nz '

        expect(Transaction.last.detail).to eq detail
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
      expect(assigns[:category_details]).to eq [category_detail.category]
    end

    it 'renders the edit template' do
      expect(response).to render_template(:edit)
    end

    context 'positive transaction amounts' do
      let(:transactions) { create_list(:transaction, 3) }
      let!(:category_detail) { create(:category_detail) }

      it 'does not include positive amounts' do
        transactions.first.update_attribute(:amount, -100.00)
        get :bulk_edit, params: { ids: transactions.map(&:id) }

        assigns[:transactions].each do |transaction|
          expect(transaction.amount).to be < 0
        end
      end
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

  describe 'update' do
    context 'new categories on transactions with the same detail' do
      let(:detail) { 'Coffee is gooooo'.parameterize }
      let(:new_category) { 'Eating out' }
      let(:transactions_same_detail) { create_list(:transaction, 5, detail: detail) }

      before do
        post :update, params: { format: 'json',
                                transactions: { ids: transactions_same_detail.map(&:id),
                                                detail: detail,
                                                category: new_category } }
      end

      it 'updates the transactions with the new category' do
        transactions_same_detail.each(&:reload)

        transactions_same_detail.each do |transaction|
          expect(transaction.category).to eq new_category.parameterize
        end
      end

      it 'creates a new category detail' do
        expect(CategoryDetail.first.detail).to eq detail.parameterize
        expect(CategoryDetail.first.category).to eq new_category.parameterize
        expect(CategoryDetail.count).to eq 1
      end

      it 'responsds with statusd 200' do
        expect(response.status).to eq 200
      end
    end

    context 'exiting categories being added to a transaction' do
      let(:transaction) { create(:transaction) }
      let(:category_detail) { create(:category_detail) }

      before do
        post :update, params: { format: 'json',
                                transactions: { ids: [transaction.id],
                                                detail: nil,
                                                category: category_detail.category } }
      end

      it 'adds the category to the transaction' do
        transaction.reload

        expect(transaction.category).to eq category_detail.category
      end

      it 'responsds with statusd 200' do
        expect(response.status).to eq 200
      end
    end

    context 'an error is raised' do
      let(:transaction) { create(:transaction) }
      let(:category_detail) { create(:category_detail) }

      before do
        post :update, params: { format: 'json',
                                transactions: { ids: ['abc'],
                                                detail: nil,
                                                category: nil } }
      end

      it 'responds with status 500' do
        expect(response.status).to eq 500
      end

      it 'has some error message in the response body' do
        expect(response.body.present?).to be true
      end
    end
  end
end
