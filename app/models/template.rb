# coding: utf-8
class Template < ActiveRecord::Base
  attr_accessible :cells, :cols, :name, :rows
  
  after_initialize :set_size
  after_initialize :set_cells
  
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
  
  def alive_cells
    self.cells.map { |row| row.map { |cell| cell.clone if cell.alive? }.compact }.flatten
  end
  
  def dead_cells
    self.cells.map { |row| row.map { |cell| cell.clone if cell.dead? }.compact }.flatten
  end
  
  private
  
  def set_cell(i, j)
    Cell.new name: self.name
  end
  
  def set_cells
    if self.cells.blank?
      self.cells = Array.new(self.rows).each_with_index.map { |row, i|
        Array.new(self.cols).each_with_index.map { |cell, j| set_cell(i, j) }
      }
    end
  end
  
  def set_size
    self.rows ||= 5
    self.cols ||= 5
  end
end
