class Cell
  attr_accessor :name, :kind
  
  @@cell_kinds = [:dead, :alive]
  
  def initialize(name, args = { })
    @name = name
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
    "#<#{self.class.name} #{@name} is #{@kind}>"
  end
  
  private
  
  def kind=(kind)
    @kind = @@cell_kinds.include?(kind) ? kind : @@cell_kinds.first
  end
end

class ColonyCell < Cell
  attr_accessor :a, :b
  
  RANGE_OF_SURVIVAL = (1..7)
  
  def initialize(name, args = { })
    super(name, args)
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
  
  def survival_range
    (@a..@b)
  end
  
  def life_position
    double_average = RANGE_OF_SURVIVAL.first + RANGE_OF_SURVIVAL.last
    (@a + @b - double_average).to_f / (@b - @a + 1)
  end
  
  def misanthropy
    RANGE_OF_SURVIVAL.last - life_position
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
    @a = RANGE_OF_SURVIVAL.include?(a) ? a : RANGE_OF_SURVIVAL.first
    @b = RANGE_OF_SURVIVAL.include?(b) && a <= b ? b : RANGE_OF_SURVIVAL.last
  end
end

class FieldCell < ColonyCell
  attr_accessor :checkpoint_type
  
  @@cell_kinds = [:dead, :alive, :checkpoint]
  CHECKPOINT_TYPES = [:finish]
  
  def initialize(name, args = { })
    super(name, args)
    self.checkpoint_type = args[:checkpoint_type]
    self
  end
  
  def is_checkpoint
    @kind = :checkpoint
    clear_genome
    self
  end
  
  def is_checkpoint?
    @kind == :checkpoint
  end
  
  private
  
  def checkpoint_type=(checkpoint_type)
    @checkpoint_type = if self.is_checkpoint?
      CHECKPOINT_TYPES.include?(checkpoint_type)? checkpoint_type : CHECKPOINT_TYPES.first
    end
  end
end
