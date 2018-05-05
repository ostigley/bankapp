require 'rails_helper'

RSpec.describe TransactionsController, type: :controller do

  describe 'new' do
    it 'renders the new template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'upload' do
    before do
      @file = fixture_file_upload('test_credit_card.csv', 'text/csv')
    end


    it 'assigns an array of transactions' do
      post :upload, params: { file: @file }
      assigns[:transactions].each do |transaction|
        expect(transaction).to be_a Transaction
      end
    end

    it 'imports transactions to the database' do
      expect(Transaction.count).to eq 0
      post :upload, params: { file: @file }

      expect(Transaction.count).to be > 0
    end

    context 'with category details already in the database' do
      before do
        category_detail = instance_double('CategoryDetail', { category: 'test category' })
        allow(CategoryDetail).to receive(:find_by).and_return(category_detail)
      end

      it 'finds the category_detail and adds it to the transaction' do
        post :upload, params: { file: @file }
        Transaction.all.each do |transaction|
          expect(transaction.category).to eq 'test category'
        end
      end
    end

    context 'with no category details already in the database' do
      it 'sets category_detail to nil for the transaction' do
        post :upload, params: { file: @file }
        Transaction.all.each do |transaction|
          expect(transaction.category).to be nil
        end
      end
    end
  end
end
