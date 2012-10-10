class Cell
  attr_accessor :state
  
  CELL_STATE = [:dead, :alive]
  
  def initialize(args = { })
    self.state = args[:state]
    self
  end
  
  def alive
    @state = :alive
    self
  end
  
  def kill
    @state = :dead
    self
  end
  
  def is_alive?
    @state == :alive
  end
  
  def is_dead?
    @state == :dead
  end
  
  private
  
  def state=(state)
    @state = state && CELL_STATE.include?(state) ? state : CELL_STATE.first
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
    @state = :alive
    self.survival = a, b
    self
  end
  
  def kill
    @state = :dead
    clear_genome
    self
  end
  
  def genome
    { survival: [@a, @b] }
  end
  
  def inspect
    "#<#{@state.capitalize} #{self.class.name}>"
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
  CELL_STATE = [:dead, :alive, :checkpoint]
  
  def is_checkpoint
    @state = :checkpoint
    clear_genome
    self
  end
  
  def is_checkpoint?
    @state == :checkpoint
  end
end
