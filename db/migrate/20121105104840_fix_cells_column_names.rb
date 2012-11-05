class FixCellsColumnNames < ActiveRecord::Migration
  def change
    rename_column :colonies,  :cells, :text_cells
    rename_column :templates, :cells, :text_cells
    rename_column :fields,    :cells, :text_cells
  end
end
