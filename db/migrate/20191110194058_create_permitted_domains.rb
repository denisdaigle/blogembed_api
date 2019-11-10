class CreatePermittedDomains < ActiveRecord::Migration[6.0]
  def change
    create_table :permitted_domains do |t|
      t.integer :blog_id
      t.string :permitted_domain

      t.timestamps
    end
  end
end
