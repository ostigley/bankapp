require 'rails_helper'

RSpec.feature 'EditTransactions', type: :feature, js: true do
  context 'adding a new category in the text field' do
    context 'when transaction details are the same' do
      let!(:same_transactions) { create_list(:transaction, 2, detail: 'the same detail') }
      let!(:transaction) { create(:transaction, detail: 'a different detail') }

      before do
        # transactions
        visit '/transactions/edit/1'
        page.first('input#new_category').set 'eating out'
        page.first('input.submit').click
        sleep 2
      end

      it 'updates all the transactions that have that detail' do
        Transaction.where(detail: 'the same detail').each do |t|
          expect(t.reload.category).to eq 'eating-out'
        end
      end

      it 'adds the new category to the drop down list' do
        select 'eating out', from: 'Select a category or create one'
      end
    end
  end

  context 'choosing an existing category from the select box' do
    context 'when transaction details are the same' do
      let!(:same_transactions) { create_list(:transaction, 2, detail: 'the same detail') }
      let!(:category_details) { create(:category_detail, category: 'eating-out') }

      before do
        visit '/transactions/edit/1'

        find(:xpath, "//select[@data-id='#{same_transactions.first.id}']").select('eating-out')
        sleep 2
      end

      it 'updates all the transactions that have that detail' do
        Transaction.where(detail: 'the same detail').each do |t|
          expect(t.reload.category).to eq 'eating-out'
        end
      end

      # it 'adds the new category to the drop down list' do
      #   select 'eating out', from: 'Select a category or create one'
      # end
    end
  end
end
