# coding: utf-8
class Field < Template
  has_and_belongs_to_many :colonies
  
  LIFE_CYCLES_RANGE = (10..25)
  
  def push_colonies(colonies)
    return unless colonies
    colonies.each do |colony|
      top, left = colony[:top] || 0, colony[:left] || 0
      if (top + colony[:colony].rows > self.rows) ||
         (left + colony[:colony].cols > self.cols)
        raise Exception.new "Bad position for #{colony[:colony].name}"
      end
      set_colony colony[:colony], top, left
    end
  end
  
  def get_life(life_cycles_number)
    life_cycles = [self.cells]
    lcn = life_cycles_number.in?(LIFE_CYCLES_RANGE)? life_cycles_number : LIFE_CYCLES_RANGE.min
    lcn.times { life_cycles.push next_life_cycle }
    life_cycles
  end
  
  private
  
  def create_cell(cell)
    FieldCell.new cell
  end
  
  def find_a_neighbors(i, j)
    neighbors = [set_cell(i, j)] * 8
    neighbors[0] = self.cells[i - 1][j - 1] unless i == 0 || j == 0
    neighbors[1] = self.cells[i - 1][j]     unless i == 0
    neighbors[2] = self.cells[i - 1][j + 1] unless i == 0 || j == self.cols - 1
    neighbors[3] = self.cells[i][j + 1]     unless j == self.cols - 1
    neighbors[4] = self.cells[i + 1][j + 1] unless i == self.rows - 1 || j == self.cols - 1
    neighbors[5] = self.cells[i + 1][j]     unless i == self.rows - 1
    neighbors[6] = self.cells[i + 1][j - 1] unless i == self.rows - 1 || j == 0
    neighbors[7] = self.cells[i][j - 1]     unless j == 0
    neighbors
  end
  
  def processing_of_alive_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors_count = neighbors.map(&:alive?).count(true)
    if (self.cells[i][j].survival_range).include?(alive_neighbors_count)
      self.cells[i][j]
    else
      set_cell(i, j)
    end
  end
  
  def processing_of_dead_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors = neighbors.map{ |n| n.clone if n.alive? }.compact
    return self.cells[i][j] if alive_neighbors.empty?
    misanthropy_level = alive_neighbors.map(&:misanthropy).sum
    if ColonyCell.allowable_range_of_fertility.include?(misanthropy_level)
      a = alive_neighbors.map(&:a).sum / alive_neighbors.map(&:a).size
      b = alive_neighbors.map(&:b).sum / alive_neighbors.map(&:b).size
      name = alive_neighbors.first.name
      parents = alive_neighbors.map(&:parents).flatten.uniq
      ColonyCell.new name: name, alive: true, parents: parents, a: a, b: b
    else
      self.cells[i][j]
    end
  end
  
  def next_life_cycle
    cells = self.cells.map { |row| row.map { |cell| cell.clone } }
    self.rows.times do |i|
      self.cols.times do |j|
        if self.cells[i][j].alive?
          cells[i][j] = processing_of_alive_cell(i, j)
        else
          cells[i][j] = processing_of_dead_cell(i, j)
        end
      end
    end
    @cells = cells
    self.cells
  end
  
  def set_colony(colony, top, left)
    colony.rows.times do |i|
      colony.cols.times do |j|
        raise Exception.new "Bad position" unless self.cells[i + top][j + left].dead?
        self.cells[i + top][j + left] = colony.cells[i][j] if colony.cells[i][j].alive?
      end
    end
  end
end
