class CreatePosts < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.timestamp :date_posted
      t.string :content
      t.string :type
    end
  end
end
