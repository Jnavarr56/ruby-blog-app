class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.timestamp :date_posted
      t.string :post_title
      t.string :content
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
