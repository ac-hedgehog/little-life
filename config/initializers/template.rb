# coding: utf-8
class Template
  attr_accessor :name, :rows, :cols, :cells
  
  SIZE_RANGE = (10..100)
  
  def initialize(name, rows = SIZE_RANGE.last, cols = SIZE_RANGE.last)
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
        cell.is_alive? ? "O" : "X"
      }.join
    }.join("\n")
  end
  
  private
  
  def set_cell
    Cell.new @name
  end
  
  def set_cells
    @cells = Array.new(@rows).map { Array.new(@cols).map { set_cell } }
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
  attr_accessor :probabilities
  
  DEFAULT_PROBABILITY = 0.3
  
  def initialize(name, args = { })
    set_name name
    set_size args[:rows], args[:cols]
    set_probabilities args[:probabilities]
    set_cells
    self
  end
  
  def to_s
    "#{self.class.name} #{@name}:\n" + @cells.map { |row|
      row.map { |cell|
        cell.is_alive? ? "#{cell.a}#{cell.b}" : "  "
      }.join("|")
    }.join("\n#{'—' * @cols * 3}\n")
  end
  
  private
  
  def set_size(rows, cols)
    @rows = SIZE_RANGE.include?(rows) ? rows : SIZE_RANGE.first
    @cols = SIZE_RANGE.include?(cols) ? cols : SIZE_RANGE.first
  end
  
  def set_cell(i, j)
    alive = Random.rand(1.0) < @probabilities[i][j] ? :alive : :dead
    a = alive == :alive ? rand(ColonyCell::RANGE_OF_SURVIVAL) : nil
    b = alive == :alive ? rand(a..ColonyCell::RANGE_OF_SURVIVAL.last) : nil
    ColonyCell.new @name, kind: alive, a: a, b: b
  end
  
  def set_cells
    @cells = Array.new(@rows).each_with_index.map { |x, i|
      Array.new(@cols).each_with_index.map { |y, j|
        set_cell i, j
      }
    }
  end
  
  def set_probabilities(probabilities)
    @probabilities = if probabilities.is_a?(Array)
      probabilities.map! { |row| row.map! { |probability|
        (0..1).include?(probability)? probability : DEFAULT_PROBABILITY
      } }
    else
      Array.new(@rows).map! { Array.new(@cols).map! { DEFAULT_PROBABILITY } }
    end
  end
end

class Field < Template
  
  CYCLES_RANGE = (10..100)
  
  def initialize(name, rows = SIZE_RANGE.last, cols = SIZE_RANGE.last, args = { })
    set_name name
    @rows, @cols = rows, cols
    set_cells args[:checkpoints]
    set_colonies args[:colonies]
    self
  end
  
  def get_life(args = { })
    life_cycles = [@cells.to_json]
    cycles_number(args[:cycles_number]).times do
      life_cycles.push next_life_cycle
    end
    life_cycles
  end
  
  private
  
  def find_a_neighbors(i, j)
    neighbors = [dead_cell] * 8
    neighbors[0] = @cells[i - 1][j - 1] unless i == 0 && j == 0
    neighbors[1] = @cells[i - 1][j]     unless i == 0
    neighbors[2] = @cells[i - 1][j + 1] unless i == 0 && j == @cols - 1
    neighbors[3] = @cells[i][j + 1]     unless j == @cols - 1
    neighbors[4] = @cells[i + 1][j + 1] unless i == @rows - 1 && j == @cols - 1
    neighbors[5] = @cells[i + 1][j]     unless i == @rows - 1
    neighbors[6] = @cells[i + 1][j - 1] unless i == @rows - 1 && j == 0
    neighbors[7] = @cells[i][j - 1]     unless j == 0
    neighbors
  end
  
  def processing_of_alive_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors_count = neighbors.map(&:kind).count(:alive)
    unless (@cells[i][j].survival_range).include?(alive_neighbors_count)
      @cells[i][j] = dead_cell
    end
  end
  
  def next_life_cycle
    @rows.times do |i|
      @cols.times do |j|
        case @cells[i][j].kind
        when :alive
          processing_of_alive_cell(i, j)
        when :dead
        when :checkpoint
        end
      end
    end
    @cells.to_json
  end
  
  def cycles_number(cycles_number)
    CYCLES_RANGE.include?(cycles_number)? cycles_number : CYCLES_RANGE.first
  end
  
  def dead_cell
    FieldCell.new @name
  end
  
  def checkpoint_cell(checkpoint_type)
    FieldCell.new @name, kind: :checkpoint, checkpoint_type: checkpoint_type
  end
  
  def set_checkpoints(checkpoints)
    raise Exception.new 'Bad size' unless checkpoints.size == @rows &&
                                          checkpoints.first.size == @cols
    @cells = checkpoints.map { |row|
      row.map { |checkpoint|
        checkpoint ? checkpoint_cell(checkpoint.to_sym) : dead_cell
      }
    }
  end
  
  def set_cells(checkpoints = nil)
    if checkpoints
      set_checkpoints(checkpoints)
    else
      @cells = Array.new(@rows).map { Array.new(@cols).map { dead_cell } }
    end
  end
  
  def set_colony(colony, top, left)
    colony.rows.times do |i|
      colony.cols.times do |j|
        raise Exception.new "Bad position" unless @cells[i + top][j + left].is_dead?
        @cells[i + top][j + left] = colony.cells[i][j] if colony.cells[i][j].is_alive?
      end
    end
  end
  
  def set_colonies(colonies)
    return unless colonies
    colonies.each do |colony|
      top = colony[:top] || 0
      left = colony[:left] || 0
      if (top + colony[:colony].rows > @rows) ||
         (left + colony[:colony].cols > @cols)
        raise Exception.new "Bad position for #{colony[:colony].name}"
      end
      set_colony colony[:colony], top, left
    end
  end
end
