class CreateInteractJoins < ActiveRecord::Migration[5.2]
  def change
    create_table :interact_joins do |t|
      t.integer :post_id
      t.integer :post_type_id
      t.integer :interacting_user_id
    end
  end
end
