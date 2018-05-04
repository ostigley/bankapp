# frozen_string_literal: true

module TransactionsHelper
  def category_detail_options
    options_for_select(@category_details.map { |c| [c.category, c.detail] })
  end
end
