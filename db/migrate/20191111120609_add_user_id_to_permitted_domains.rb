class AddUserIdToPermittedDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :permitted_domains, :user_id, :integer
  end
end
