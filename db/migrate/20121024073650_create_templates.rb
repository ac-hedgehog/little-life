class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name,   :default => "Field"
      t.integer :rows,  :default => 5
      t.integer :cols,  :default => 5
      t.text :cells

      t.timestamps
    end
  end
end
