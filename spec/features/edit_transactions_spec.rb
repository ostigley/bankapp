require 'rails_helper'

RSpec.feature 'EditTransactions', type: :feature, js: true do
  context 'adding a new category in the text field' do
    context 'when transaction details are the same' do
      let!(:transactions) { create_list(:transaction, 2, detail: 'the same detail') }

      before do
        # transactions
        visit '/transactions/edit/1'
        page.first('input#new_category').set 'eating out'
        page.first('input.submit').click
      end

      it 'updates all the transactions that have that detail' do
        sleep 1

        Transaction.all.each do |t|
          expect(t.reload.category).to eq 'eating-out'
        end
      end

      
    end
  end
end
