class AddSignUpCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :sign_up_code, :string
  end
end
