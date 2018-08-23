class CreateInteracts < ActiveRecord::Migration[5.2]
  def change
    create_table :interacts do |t|
      t.string :interact_type  
    end
  end
end
