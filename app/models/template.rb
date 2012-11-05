# coding: utf-8
class Template < ActiveRecord::Base
  attr_accessible :text_cells, :cols, :name, :rows
  
  after_initialize :set_size
  after_initialize :set_cells
  before_save :cells_to_text
  
  def inspect
    "#<#{self.class.name} #{self.name}: #{self.rows}x#{self.cols}>"
  end
  
  def to_s
    "#{self.class.name} #{self.name}:\n" + self.cells.map { |row|
      row.map { |cell|
        cell.alive? ? "O" : "X"
      }.join
    }.join("\n")
  end
  
  def clone
    self.class.new  name: self.name.clone, rows: self.rows, cols: self.cols,
                    text_cells: @cells.map { |row| row.map { |cell| cell.clone } }
  end
  
  def alive_cells
    self.cells.map { |row| row.map { |cell| cell.clone if cell.alive? }.compact }.flatten
  end
  
  def dead_cells
    self.cells.map { |row| row.map { |cell| cell.clone if cell.dead? }.compact }.flatten
  end
  
  def cells
    @cells || text_to_cells
  end
  
  private
  
  def text_to_cells
    @cells = if self.text_cells.is_a? String
      ActiveSupport::JSON.decode(self.text_cells).map { |row|
        row.map { |cell| create_cell cell.symbolize_keys }
      }
    else
      self.text_cells
    end
  end
  
  def cells_to_text
    self.text_cells = @cells.to_json unless self.text_cells
  end
  
  def create_cell(cell)
    Cell.new cell
  end
  
  def set_cell(i, j)
    Cell.new name: self.name
  end
  
  def set_cells
    if @cells.blank?
      if self.text_cells.blank?
        @cells = Array.new(self.rows).each_with_index.map { |row, i|
          Array.new(self.cols).each_with_index.map { |cell, j| set_cell(i, j) }
        }
      else
        text_to_cells
      end
    end
  end
  
  def set_size
    self.rows ||= 5
    self.cols ||= 5
  end
end
