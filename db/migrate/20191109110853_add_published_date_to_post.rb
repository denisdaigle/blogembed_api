class AddPublishedDateToPost < ActiveRecord::Migration[6.0]
  def change
    add_column :posts, :last_published, :datetime
  end
end
