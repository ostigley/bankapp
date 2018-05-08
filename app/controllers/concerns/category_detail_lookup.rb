# frozen_string_literal: true

module CategoryDetailLookup
  extend ActiveSupport::Concern

  def all_categories
    @category_details = CategoryDetail.all.map(&:category).uniq
  end

  def find_or_create_category_detail(transaction)
    category = CategoryDetail.find_or_create_by!(detail: transaction[:detail].parameterize) do |cd|
      cd.category = transaction[:category].parameterize
    end

    category.category
  end

  def add_category_to_transactions
    @transactions.each do |transaction|
      if transaction.amount.positive?
        transaction.update_attribute(:category, 'income')
      else
        category = CategoryDetail.find_by(detail: transaction.detail.parameterize)

        transaction.update_attribute(:category, category&.category)
      end
    end
  end
end
