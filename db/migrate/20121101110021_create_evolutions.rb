class CreateEvolutions < ActiveRecord::Migration
  def change
    create_table :evolutions do |t|
      t.string :field_name,           :default => 'Evolution Field'
      t.integer :field_rows
      t.integer :field_cols
      t.string :main_name,            :default => 'Creature'
      t.integer :main_top,            :default => 0
      t.integer :main_left,           :default => 0
      t.integer :life_cycles_number
      t.integer :population_size
      t.integer :evolution_steps
      t.integer :mutation_level
      t.integer :task_id

      t.timestamps
    end
  end
end
