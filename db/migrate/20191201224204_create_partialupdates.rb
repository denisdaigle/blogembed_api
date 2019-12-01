class CreatePartialupdates < ActiveRecord::Migration[6.0]
  def change
    create_table :partialupdates do |t|
      t.integer :post_id
      t.integer :final_partial_index
      t.integer :lastest_partial_index
      t.text :partial_content

      t.timestamps
    end
  end
end
