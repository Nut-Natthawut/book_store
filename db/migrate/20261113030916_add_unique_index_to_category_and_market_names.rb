class AddUniqueIndexToCategoryAndMarketNames < ActiveRecord::Migration[8.1]
  def change
    add_index :categories, "lower(name)", unique: true, name: "index_categories_on_lower_name"
    add_index :markets, "lower(name)", unique: true, name: "index_markets_on_lower_name"
  end
end
