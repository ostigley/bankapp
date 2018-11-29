require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'scope sum_month_category' do
    let!(:transactions) { create_list(:transaction, 2, {
      category: 'eating_out',
      amount: 10.00,
      transaction_date: Time.zone.now.to_date
    })
   }

    it 'sums the total transactions for that month in that category' do
      expect(Transaction.sum_month_category('eating_out', Time.zone.now.to_date)).to eq 20.00
    end
  end

  describe 'scope category_to_day_in_month' do
    let!(:transactions_month_1) do
      create_list(:transaction, 2, category: 'eating_out').each_with_index do |transaction, i|
        transaction.update(transaction_date: Date.new(2018, 1, i * 10 + 1))
      end
    end

    let!(:transactions_month_2) do
      create_list(:transaction, 2, category: 'eating_out').each_with_index do |transaction, i|
        transaction.update(transaction_date: Date.new(2018, 2, i * 10 + 1))
      end
    end

    let!(:transactions_wrong_category) do
      create_list(:transaction, 2, category: 'groceries').each_with_index do |transaction, i|
        transaction.update(transaction_date: Date.new(2018, 1, (i + 10)))
      end
    end

    context 'Day 15' do
      let(:transactions) { Transaction.category_to_day_in_month(:eating_out, 15) }

      it 'returns some transactions' do
        expect(transactions.present?).to be true
      end

      it 'returns transactions before day parameter in a month' do
        transactions.each do |transaction|
          day = transaction.transaction_date.day

          expect(day).to be <= 15
        end
      end

      it 'returns transactions with the correct category' do
        transactions.each do |transaction|
          expect(transaction.category).to eq 'eating_out'
        end
      end
    end
  end
end

