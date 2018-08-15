class EditHashtagsType < ActiveRecord::Migration[5.2]
  def change
    remove_column :hashtags, :hashtag, :integer
    add_column :hashtags, :hashtag, :string
  end
end
