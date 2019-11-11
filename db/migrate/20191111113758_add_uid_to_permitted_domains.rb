class AddUidToPermittedDomains < ActiveRecord::Migration[6.0]
  def change
    add_column :permitted_domains, :uid, :string
  end
end
