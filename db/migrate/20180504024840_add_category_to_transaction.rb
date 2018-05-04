class AddCategoryToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :category, :string
  end
end
