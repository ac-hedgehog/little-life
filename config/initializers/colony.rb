class Cell
  attr_accessor :a, :b
  
  RANGE_OF_SURVIVAL = (1..7).to_a
  
  def initialize(args = { })
    @alive = args[:alive] ? true : false
    self.survival = args[:a], args[:b] if @alive
  end
  
  def alive!(a, b)
    @alive = true
    self.survival = a, b
  end
  
  def kill!
    @alive = false
    @a, @b = nil
  end
  
  def alive?
    @alive
  end
  
  def genome
    { survival: [@a, @b] }
  end
  
  private
  
  def survival=(*args)
    a, b = args.first
    ros = RANGE_OF_SURVIVAL
    @a = a && a.is_a?(Fixnum) && ros.include?(a) ? a : ros.first
    @b = b && b.is_a?(Fixnum) && ros.include?(b) && a <= b ? b : ros.last
  end
end

class Colony
  attr_accessor :rows, :cols, :body
  
  def initialize(args = { })
    @rows = args[:rows] || 1
    @cols = args[:cols] || 1
    new_body
  end
  
  def initialize(rows = 1, cols = 1)
    @rows, @cols = rows, cols
    new_body
  end
  
  private
  
  def new_body
    @body = Array.new(@rows).map! { Array.new(@cols).map! { Cell.new } }
  end
end
