class CreateTrades < ActiveRecord::Migration[7.0]
  def change
    create_table :trades do |t|
      t.string :trade_type
      t.integer :user_id
      t.string :symbol
      t.integer :shares
      t.integer :price
      t.integer :timestamp

      t.timestamps
    end
  end
end
