class AddStatusToPost < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :status, :string, :default => "draft"
  end
end
