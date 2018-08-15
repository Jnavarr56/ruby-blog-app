class CreateInteracts < ActiveRecord::Migration[5.2]
  def change
    create_table :interacts do |t|
      t.integer :post_id
      t.string :type  
    end
  end
end
