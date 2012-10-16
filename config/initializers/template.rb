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
  
  LIFE_CYCLES_RANGE = (10..100)
  
  def initialize(name, rows = SIZE_RANGE.last, cols = SIZE_RANGE.last, args = { })
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
    neighbors = [dead_cell] * 8
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
    alive_neighbors_count = neighbors.map(&:kind).count(:alive)
    if (@cells[i][j].survival_range).include?(alive_neighbors_count)
      @cells[i][j]
    else
      dead_cell
    end
  end
  
  def processing_of_dead_cell(i, j)
    neighbors = find_a_neighbors(i, j)
    alive_neighbors = neighbors.map { |n| n if n.is_alive? }.compact
    return @cells[i][j] if alive_neighbors.empty?
    all_a = alive_neighbors.map &:a
    all_b = alive_neighbors.map &:b
    if (12..14).include?(alive_neighbors.map(&:misanthropy).sum)
      a = all_a.sum / all_a.size
      b = all_b.sum / all_b.size
      name = alive_neighbors.first.name
      ColonyCell.new name, kind: :alive, a: a, b: b
    else
      @cells[i][j]
    end
  end
  
  def next_life_cycle
    cells = @cells.map { |row| row.map { |cell| cell.clone } }
    @rows.times do |i|
      @cols.times do |j|
        case @cells[i][j].kind
        when :alive
          cells[i][j] = processing_of_alive_cell(i, j)
        when :dead
          cells[i][j] = processing_of_dead_cell(i, j)
        when :checkpoint
        end
      end
    end
    @cells = cells
    @cells
  end
  
  def life_cycles_number(life_cycles_number)
    if LIFE_CYCLES_RANGE.include?(life_cycles_number)?
      life_cycles_number
    else
      LIFE_CYCLES_RANGE.first
    end
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
      top, left = colony[:top] || 0, colony[:left] || 0
      if (top + colony[:colony].rows > @rows) ||
         (left + colony[:colony].cols > @cols)
        raise Exception.new "Bad position for #{colony[:colony].name}"
      end
      set_colony colony[:colony], top, left
    end
  end
end

def Evolution
  attr_accessor :main_colony, :population, :population_size
  
  DEFAULT_TASK = { goal: :maximizing }
  POPULATION_SIZE_RANGE = (5..20)
  
  def initialize(args = { })
    @field_rows, @field_cols = args[:field_rows], args[:field_cols]
    
    @main_colony = args[:main_colony]
    @main_top, @main_left = args[:main_top] || 0, args[:main_left] || 0
    @other_colonies = args[:other_colonies] || []
    
    @population = []
    @population_size = args[:population_size] || POPULATION_SIZE_RANGE.min
    @life_cycles_number = args[:life_cycles_number] || LIFE_CYCLES_RANGE.min
    @evolution_step = args[:evolution_step] || 0
    @task = args[:task] || DEFAULT_TASK
    self
  end
  
  def evolve
    @evolution_step += 1
    @population_size.times do |population_number|
      main_colony = if population_number == 1
        @main_colony || Colony.new("Creature")
      else
        if @evolution_step == 1 && !@main_colony
          Colony.new("Creature")
        else
          mutate_main_colony
        end
      end
      all_colonies = @other_colonies
      all_colonies.push { colony: main_colony, top: @main_top, left: @main_left }
      field = Field.new "Evolution Field", @field_rows, @field_cols,
                                           colonies: all_colonies
      life_cycles = field.get_life cycles_number: @life_cycles_number
      person = { colony: main_colony, field: field, life_cycles: life_cycles }
      @population.push person
    end
    @population.map &:life_cycles
  end
  
  private
  
  def mutate_main_colony
    Colony.new("Creature")
  end
end
