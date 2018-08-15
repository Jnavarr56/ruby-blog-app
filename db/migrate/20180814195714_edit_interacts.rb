class EditInteracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :interacts, :post_id, :integer
    rename_column :interacts, :type, :interact_type
  end
end
