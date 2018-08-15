class CreateFollowers < ActiveRecord::Migration[5.2]
  def change
    create_table :followers do |t|
      t.integer :followed_user_id
      t.integer :following_user_id
    end
  end
end
