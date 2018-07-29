class AddIndexToTransactionHash < ActiveRecord::Migration[5.1]
  def change
    add_index :transactions, :transaction_hash
  end
end
