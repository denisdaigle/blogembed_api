class CreateApiAccessKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :api_access_keys do |t|
      t.string :api_key
      t.string :secret
      t.string :client_name
      t.boolean :active, :default => false

      t.timestamps
    end
  end
end
