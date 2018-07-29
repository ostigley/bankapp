class AddHashToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :transaction_hash, :string
  end
end
