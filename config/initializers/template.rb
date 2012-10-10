class Template
  attr_accessor :rows, :cols, :cells
  
  SIZE_RANGE = (10..100)
  
  def initialize(rows = SIZE_RANGE.last, cols = SIZE_RANGE.last)
    @rows, @cols = rows, cols
    new_cells
    self
  end
  
  def inspect
    "#<#{self.class.name}: #{@rows}x#{@cols}>"
  end
  
  def to_s
    @cells.map { |row|
      row.map { |cell|
        cell.is_alive? ? "." : " "
      }.join
    }.join("\n")
  end
  
  private
  
  def new_cell
    Cell.new
  end
  
  def new_cells
    @cells = Array.new(@rows).map { Array.new(@cols).map { new_cell } }
  end
end

class Colony < Template
  attr_accessor :probabilities
  
  DEFAULT_PROBABILITY = 0.3
  
  def initialize(args = { })
    set_size args[:rows], args[:cols]
    set_probabilities args[:probabilities]
    set_cells
    self
  end
  
  def to_s
    @cells.map { |row|
      row.map { |cell|
        cell.is_alive? ? "#{cell.a}#{cell.b}" : "  "
      }.join(" ")
    }.join("\n")
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
    ColonyCell.new kind: alive, a: a, b: b
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

class ColonyLayer < Template
  
  private
  
  def new_cell
    ColonyCell.new
  end
end

class Field < Template
  
  private
  
  def new_cell
    FieldCell.new
  end
end
