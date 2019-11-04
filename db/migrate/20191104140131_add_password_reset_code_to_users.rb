class AddPasswordResetCodeToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :password_reset_code, :string
  end
end
