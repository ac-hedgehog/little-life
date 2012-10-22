class Cell
  attr_accessor :name, :alive, :id, :parents
  
  def initialize(args = { })
    @name = args[:name]
    @alive = args[:alive] || false
    @id = args[:id] if @alive
    @parents = @alive && args[:parents] ? args[:parents] : []
    @parents.push @id if @id
    self
  end
  
  def alive
    @alive = true
    self
  end
  
  def kill
    @alive = false
    @id = nil
    @parents = []
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
    super
    self.survival = a, b
    self
  end
  
  def kill
    super
    clear_genome
    self
  end
  
  def survival_range
    (@a..@b)
  end
  
  def rand_survival
    @a, @b = ColonyCell.rand_survival
    self
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
  
  def self.rand_survival
    [rand(RANGE_OF_SURVIVAL), rand(RANGE_OF_SURVIVAL)].sort
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
  attr_accessor :fungus
  
  def initialize(args = { })
    super(args)
    @fungus = args[:fungus] ? args[:fungus] : false
    self
  end
end
