class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password
      t.date :dob
      t.timestamp :created_at
      t.timestamp :updated_at
      t.float :time_logged
      t.string :verify_code
      t.boolean :verified
      t.string :update_code
      t.string :new_first_name
      t.string :new_last_name
      t.string :new_email_name
      t.string :new_passwords
    end
  end
end
