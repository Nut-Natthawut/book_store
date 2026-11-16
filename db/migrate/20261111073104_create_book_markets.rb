class CreateBookMarkets < ActiveRecord::Migration[8.1]
  def change
    create_table :book_markets do |t|
      t.references :book, null: false, foreign_key: true
      t.references :market, null: false, foreign_key: true

      t.timestamps
    end

    add_index :book_markets, [ :book_id, :market_id ], unique: true
  end
end
