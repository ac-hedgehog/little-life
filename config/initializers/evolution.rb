class Evolution
  attr_accessor :main_colony, :population, :population_size
  
  POPULATION_SIZE_RANGE = (5..20)
  EVOLUTION_STEPS_RANGE = (3..20)
  TASK_GOALS = [:maximizing]
  DEFAULT_TASK = { goal: TASK_GOALS.first }
  
  def initialize(args = { })
    @field_rows, @field_cols = args[:field_rows], args[:field_cols]
    
    @main_colony = args[:main_colony]
    @main_top, @main_left = args[:main_top] || 0, args[:main_left] || 0
    @other_colonies = args[:other_colonies] || []
    
    @population_size = args[:population_size] || POPULATION_SIZE_RANGE.min
    @life_cycles_number = args[:life_cycles_number] || LIFE_CYCLES_RANGE.min
    @evolution_steps = args[:evolution_steps] || EVOLUTION_STEPS_RANGE.min
    
    @task = args[:task] || DEFAULT_TASK
    @task = DEFAULT_TASK unless TASK_GOALS.include?(@task[:goal])
    self
  end
  
  def get_person_for_population(step, population_number)
    main_colony = get_main_colony_for_evolution_step step, population_number
    all_colonies = @other_colonies.clone
    all_colonies.push({ colony: main_colony, top: @main_top, left: @main_left })
    field = Field.new "Evolution Field", @field_rows, @field_cols,
                                         colonies: all_colonies
    field_clone = field.clone
    life_cycles = field_clone.get_life cycles_number: @life_cycles_number
    main_colony_after = Colony.new "Creature", cells: life_cycles.last
    task_points = calculate_task_points_for main_colony, main_colony_after
    { colony: main_colony, life_cycles: life_cycles, task_points: task_points }
  end
  
  def evolution_step(step)
    population = []
    @population_size.times do |population_number|
      population.push(get_person_for_population(step, population_number))
    end
    population.map { |person| person }
  end
  
  def evolve
    evolution = []
    @evolution_steps.times do |step|
      evolution.push(evolution_step(step))
    end
    evolution
  end
  
  private
  
  def maximizing_points_for(colony_before, colony_after)
    alive_cells_before = colony_before.alive_cells
    alive_cells_after = colony_after.alive_cells
    points = alive_cells_after.count + colony_before.rows * colony_before.cols / alive_cells_before.count.to_f
    
    significant_cells = alive_cells_after.map{|c|c.parents}.flatten.uniq.map { |id|
      id if alive_cells_before.map(&:id).include?(id)
    }.compact.sort
    
    { points: points.round(2), cells: significant_cells }
  end
  
  def calculate_task_points_for(colony_before, colony_after)
    case @task[:goal]
    when :maximizing
      maximizing_points_for colony_before, colony_after
    end
  end
  
  def mutate_main_colony
    Colony.new("Creature")
  end
  
  def get_main_colony_for_evolution_step(step, population_number)
    if population_number == 1
      @main_colony || Colony.new("Creature")
    else
      if step == 1 && !@main_colony
        Colony.new("Creature")
      else
        mutate_main_colony
      end
    end
  end
end
