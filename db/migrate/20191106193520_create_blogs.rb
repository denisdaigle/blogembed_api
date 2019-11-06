class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs do |t|
      t.integer :user_id
      t.string :name
      t.string :uid

      t.timestamps
    end
  end
end
