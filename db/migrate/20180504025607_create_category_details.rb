class CreateCategoryDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :category_details do |t|
      t.string :detail
      t.string :category
    end
    add_index :category_details, :detail
  end
end
