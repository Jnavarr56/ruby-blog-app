class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.date :dob
      t.timestamp :last_accessed
      t.float :time_logged
      t.string :verify_code
      t.boolean :verified
    end
  end
end
