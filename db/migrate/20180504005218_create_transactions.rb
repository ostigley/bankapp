class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.date :transaction_date
      t.string :detail
      t.float :amount
    end
  end
end
