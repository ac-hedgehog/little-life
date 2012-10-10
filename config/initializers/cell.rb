class Cell
  attr_accessor :kind
  
  CELL_KINDS = [:dead, :alive]
  
  def initialize(args = { })
    self.kind = args[:kind]
    self
  end
  
  def alive
    @kind = :alive
    self
  end
  
  def kill
    @kind = :dead
    self
  end
  
  def is_alive?
    @kind == :alive
  end
  
  def is_dead?
    @kind == :dead
  end
  
  def inspect
    "#<#{@kind.capitalize} #{self.class.name}>"
  end
  
  private
  
  def kind=(kind)
    @kind = kind && CELL_KINDS.include?(kind) ? kind : CELL_KINDS.first
  end
end

class ColonyCell < Cell
  attr_accessor :a, :b
  
  RANGE_OF_SURVIVAL = (1..7).to_a
  
  def initialize(args = { })
    super(args)
    self.survival = args[:a], args[:b] if self.is_alive?
    self
  end
  
  def alive(a, b)
    @kind = :alive
    self.survival = a, b
    self
  end
  
  def kill
    @kind = :dead
    clear_genome
    self
  end
  
  def genome
    { survival: [@a, @b] }
  end
  
  private
  
  def clear_genome
    @a, @b = nil
  end
  
  def survival=(*args)
    a, b = args.first
    @a = a && RANGE_OF_SURVIVAL.include?(a) ? a : RANGE_OF_SURVIVAL.first
    @b = b && RANGE_OF_SURVIVAL.include?(b) && a <= b ? b : RANGE_OF_SURVIVAL.last
  end
end

class FieldCell < ColonyCell
  CELL_KINDS = [:dead, :alive, :checkpoint]
  
  def is_checkpoint
    @kind = :checkpoint
    clear_genome
    self
  end
  
  def is_checkpoint?
    @kind == :checkpoint
  end
end
