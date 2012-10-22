# coding: utf-8
class Template
  attr_accessor :name, :rows, :cols, :cells
  
  SIZE_RANGE = (5..50)
  
  def initialize(name, rows = SIZE_RANGE.max, cols = SIZE_RANGE.min)
    set_name name
    @rows, @cols = rows, cols
    set_cells
    self
  end
  
  def inspect
    "#<#{self.class.name} #{@name}: #{@rows}x#{@cols}>"
  end
  
  def to_s
    "#{self.class.name} #{@name}:\n" + @cells.map { |row|
      row.map { |cell|
        cell.alive? ? "O" : "X"
      }.join
    }.join("\n")
  end
  
  def alive_cells
    @cells.map { |row| row.map { |cell| cell.clone if cell.alive? }.compact }.flatten
  end
  
  def dead_cells
    @cells.map { |row| row.map { |cell| cell.clone if cell.dead? }.compact }.flatten
  end
  
  private
  
  def set_cell(i, j)
    Cell.new name: @name
  end
  
  def set_cells
    @cells = Array.new(@rows).each_with_index.map { |row, i|
      Array.new(@cols).each_with_index.map { |cell, j| set_cell(i, j) }
    }
  end
  
  def set_name(name)
    raise Exception.new 'Bad name' unless name.is_a?(String)
    
    words_count = 2
    valid_symbols = ('A'..'z').to_a.push(' ')
    
    @name = name.split('')
                .map{ |l| valid_symbols.include?(l) ? l : nil }
                .compact.join.split(' ').first(words_count)
                .map{ |n| n.capitalize }.join(' ')
  end
end

class Colony < Template
  attr_accessor :probability
  
  DEFAULT_PROBABILITY = 0.3
  MUTATION_LEVELS = (1..10)
  
  def initialize(name, args = { })
    set_name name
    set_size args[:rows], args[:cols]
    @probability = args[:probability] || DEFAULT_PROBABILITY
    @cells = args[:cells] ? args[:cells] : set_cells
    self
  end
  
  def to_s
    "#{self.class.name} #{@name}:\n" + @cells.map { |row|
      row.map { |cell|
        cell.alive? ? "#{cell.a}#{cell.b}" : "  "
      }.join("|")
    }.join("\n#{'—' * @cols * 3}\n")
  end
  
  def clone
    Colony.new @name.clone, rows: @rows, cols: @cols,
               cells: @cells.map { |row| row.map { |cell| cell.clone } }
  end
  
  def mutate(mutation_level = MUTATION_LEVELS.first)
    mutation_level.times do
      i = rand(@rows)
      j = rand(@cols)
      @cells[i][j] = ColonyCell.new({ name: @name, alive: true }) if @cells[i][j].dead?
      @cells[i][j].rand_survival
    end
    self.clone
  end
  
  private
  
  def set_size(rows, cols)
    @rows = SIZE_RANGE.include?(rows) ? rows : SIZE_RANGE.min
    @cols = SIZE_RANGE.include?(cols) ? cols : SIZE_RANGE.min
  end
  
  def set_cell(i, j)
    alive = Random.rand(1.0) < @probability
    a, b = alive ? ColonyCell.rand_survival : nil
    ColonyCell.new name: @name, alive: alive, a: a, b: b
  end
  
  def set_cells
    Array.new(@rows).each_with_index.map { |row, i|
      Array.new(@cols).each_with_index.map { |cell, j|
        set_cell(i, j)
      }
    }
  end
end

class Field < Template
  
  LIFE_CYCLES_RANGE = (10..100)
  
  def initialize(name, rows = SIZE_RANGE.min, cols = SIZE_RANGE.min, args = { })
    set_name name
    @rows, @cols = rows, cols
    set_cells args[:checkpoints]
    set_colonies args[:colonies]
    self
  end
  
  def get_life(args = { })
    life_cycles = [@cells]
    life_cycles_number(args[:life_cycles_number]).times do
      life_cycles.push next_life_cycle
    end
    life_cycles
  end
  
  private
  
  def find_a_neighbors(i, j)
    neighbors = [dead_cell(i, j)] * 8
    neighbors[0] = @cells[i - 1][j - 1] unless i == 0 || j == 0
    neighbors[1] = @cells[i - 1][j]     unless i == 0
    neighbors[2] = @cells[i - 1][j + 1] unless i == 0 || j == @cols - 1
    neighbors[3] = @cells[i][j + 1]     unless j == @cols - 1
    neighbors[4] = @cells[i + 1][j + 1] unless i == @rows - 1 || j == @cols - 1
    neighbors[5] = @cells[i + 1][j]     unless i == @rows - 1
    neighbors[6] = @cells[i + 1][j - 1] unless i == @rows - 1 || j == 0
    neighbors[7] = @cells[i][j - 1]     unless j == 0
    neighbors
  end
  
  def processing_of_alive_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors_count = neighbors.map(&:alive?).count(true)
    if (@cells[i][j].survival_range).include?(alive_neighbors_count)
      @cells[i][j]
    else
      dead_cell(i, j)
    end
  end
  
  def processing_of_dead_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors = neighbors.map{ |n| n.clone if n.alive? }.compact
    return @cells[i][j] if alive_neighbors.empty?
    misanthropy_level = alive_neighbors.map(&:misanthropy).sum
    if ColonyCell.allowable_range_of_fertility.include?(misanthropy_level)
      a = alive_neighbors.map(&:a).sum / alive_neighbors.map(&:a).size
      b = alive_neighbors.map(&:b).sum / alive_neighbors.map(&:b).size
      name = alive_neighbors.first.name
      ColonyCell.new  name: name, alive: true, a: a, b: b
    else
      @cells[i][j]
    end
  end
  
  def next_life_cycle
    cells = @cells.map { |row| row.map { |cell| cell.clone } }
    @rows.times do |i|
      @cols.times do |j|
        if @cells[i][j].alive?
          cells[i][j] = processing_of_alive_cell(i, j)
        else
          cells[i][j] = processing_of_dead_cell(i, j)
        end
      end
    end
    @cells = cells
    @cells
  end
  
  def life_cycles_number(life_cycles_number)
    if LIFE_CYCLES_RANGE.include?(life_cycles_number)
      life_cycles_number
    else
      LIFE_CYCLES_RANGE.min
    end
  end
  
  def dead_cell(i, j)
    FieldCell.new name: @name
  end
  
  def checkpoint_cell(i, j, checkpoint_type)
    FieldCell.new name: @name,
                  checkpoint: checkpoint_type
  end
  
  def set_checkpoints(checkpoints)
    checkpoints.each do |checkpoint|
      i, j = checkpoint[:coordinates].first, checkpoint[:coordinates].second
      @cells[i][j] = checkpoint_cell(i, j, checkpoint[:type].to_sym)
    end
  end
  
  def set_cells(checkpoints = nil)
    @cells = Array.new(@rows).each_with_index.map { |row, i|
      Array.new(@cols).each_with_index.map { |cell, j| dead_cell(i, j) }
    }
    set_checkpoints(checkpoints) if checkpoints
  end
  
  def set_colony(colony, top, left)
    colony.rows.times do |i|
      colony.cols.times do |j|
        raise Exception.new "Bad position" unless @cells[i + top][j + left].dead?
        @cells[i + top][j + left] = colony.cells[i][j] if colony.cells[i][j].alive?
      end
    end
  end
  
  def set_colonies(colonies)
    return unless colonies
    colonies.each do |colony|
      top, left = colony[:top] || 0, colony[:left] || 0
      if (top + colony[:colony].rows > @rows) ||
         (left + colony[:colony].cols > @cols)
        raise Exception.new "Bad position for #{colony[:colony].name}"
      end
      set_colony colony[:colony], top, left
    end
  end
end
