class CreateHashtagJoins < ActiveRecord::Migration[5.2]
  def change
    create_table :hashtag_joins do |t|
      t.integer :hashtag_id
      t.integer :post_id
    end
  end
end
