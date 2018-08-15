class AddPasswordFieldToAccount < ActiveRecord::Migration[5.2]
  def change
    change_table :accounts do |t|
      add_column :password
    end
  end
end
