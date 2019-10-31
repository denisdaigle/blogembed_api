class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :uid
      t.string :status, :default => 'new'
      t.string :db_session_token

      t.timestamps
    end
  end
end
