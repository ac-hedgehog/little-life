class Template
  attr_accessor :rows, :cols, :cells
  
  DEFAULT_SIZE = { rows: 10, cols: 10 }
  
  def initialize(rows = DEFAULT_SIZE[:rows], cols = DEFAULT_SIZE[:cols])
    @rows, @cols = rows, cols
    new_cells
    self
  end
  
  def inspect
    "#<#{self.class.name}: #{@rows}x#{@cols}>"
  end
  
  private
  
  def new_cell
    Cell.new
  end
  
  def new_cells
    @cells = Array.new(@rows).map! { Array.new(@cols).map! { new_cell } }
  end
end

class Colony < Template
  
  private
  
  def new_cell
    ColonyCell.new
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
