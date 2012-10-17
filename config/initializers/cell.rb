class Cell
  attr_accessor :name, :id, :parents, :alive
  
  def initialize(args = { })
    @name = args[:name]
    @id = args[:id] || 0
    @parents = args[:parents] || []
    @alive = args[:alive] || false
    self
  end
  
  def alive
    @alive = true
    self
  end
  
  def kill
    @alive = false
    self
  end
  
  def alive?
    @alive
  end
  
  def dead?
    !@alive
  end
  
  def inspect
    "#<#{self.class.name} #{@name} is #{(@alive ? 'alive' : 'dead')}>"
  end
end

class ColonyCell < Cell
  attr_accessor :a, :b
  
  RANGE_OF_SURVIVAL = (1..7)
  
  def initialize(args = { })
    super(args)
    self.survival = args[:a], args[:b] if self.alive?
    self
  end
  
  def alive(a, b)
    @alive = true
    self.survival = a, b
    self
  end
  
  def kill
    @alive = false
    self.clear_genome
    self
  end
  
  def survival_range
    (@a..@b)
  end
  
  def life_position
    double_average = RANGE_OF_SURVIVAL.min + RANGE_OF_SURVIVAL.max
    (@a + @b - double_average).to_f / (@b - @a + 1)
  end
  
  def misanthropy
    RANGE_OF_SURVIVAL.max - life_position
  end
  
  def genome
    { survival: [@a, @b] }
  end
  
  def self.allowable_range_of_fertility
    max_mtp = RANGE_OF_SURVIVAL.max * 2 - 1
    mtp_variation = 1
    (max_mtp - mtp_variation..max_mtp + mtp_variation)
  end
  
  private
  
  def clear_genome
    @a, @b = nil
  end
  
  def survival=(*args)
    a, b = args.first
    @a = RANGE_OF_SURVIVAL.include?(a) ? a : RANGE_OF_SURVIVAL.min
    @b = RANGE_OF_SURVIVAL.include?(b) && a <= b ? b : RANGE_OF_SURVIVAL.max
  end
end

class FieldCell < ColonyCell
  attr_accessor :checkpoint
  
  CHECKPOINT_TYPES = [:finish]
  
  def initialize(args = { })
    super(args)
    @checkpoint = args[:checkpoint] if CHECKPOINT_TYPES.include?(args[:checkpoint])
    self
  end
end
