class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name,   :default => "Field"
      t.integer :rows,  :default => 10
      t.integer :cols,  :default => 10
      t.text :cells

      t.timestamps
    end
  end
end
