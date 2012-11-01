# coding: utf-8
class Colony < Template
  has_and_belongs_to_many :fields
  
  PROBABILITY = 0.3
  MUTATION_LEVELS = (1..10)
  
  def to_s
    "#{self.class.name} #{self.name}:\n" + self.cells.map { |row|
      row.map { |cell|
        cell.alive? ? "#{cell.a}#{cell.b}" : "  "
      }.join("|")
    }.join("\n#{'—' * self.cols * 3}\n")
  end
  
  def mutate(mutation_level = MUTATION_LEVELS.first)
    mutation_level.times do
      i = rand(self.rows)
      j = rand(self.cols)
      id = i * self.cols + j
      if self.cells[i][j].alive?
        self.cells[i][j].kill if rand(2) == 1
      else
        self.cells[i][j] = ColonyCell.new name: self.name, alive: true, id: id
      end
      self.cells[i][j].rand_survival if self.cells[i][j].alive?
    end
    self.clone
  end
  
  def truncate_by(ids, truncate_level = nil)
    truncate_level = truncate_level.nil? ? self.rows * self.cols : truncate_level.to_i
    max_truncate = self.alive_cells.size
    truncate_level = max_truncate - 1 unless truncate_level < max_truncate
    self.rows.times do |i|
      self.cols.times do |j|
        if self.cells[i][j].alive? && !ids.include?(self.cells[i][j].id)
          self.cells[i][j].kill
          truncate_level -= 1
        end
        return self unless truncate_level > 0
      end
    end
    self
  end
  
  private
  
  def set_cell(i, j)
    alive = Random.rand(1.0) < PROBABILITY
    a, b = alive ? ColonyCell.rand_survival : nil
    id = alive ? i * self.cols + j : nil
    ColonyCell.new name: self.name, alive: alive, id: id, a: a, b: b
  end
  
  def set_cells
    if self.cells.blank?
      self.cells = Array.new(self.rows).each_with_index.map { |row, i|
        Array.new(self.cols).each_with_index.map { |cell, j|
          set_cell(i, j)
        }
      }
    end
  end
end
