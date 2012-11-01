class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :goal

      t.timestamps
    end
  end
end
