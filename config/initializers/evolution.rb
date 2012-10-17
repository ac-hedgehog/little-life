class Evolution
  attr_accessor :main_colony, :population, :population_size
  
  DEFAULT_TASK = { goal: :maximizing }
  POPULATION_SIZE_RANGE = (5..20)
  EVOLUTION_STEPS_RANGE = (3..20)
  
  def initialize(args = { })
    @field_rows, @field_cols = args[:field_rows], args[:field_cols]
    
    @main_colony = args[:main_colony]
    @main_top, @main_left = args[:main_top] || 0, args[:main_left] || 0
    @other_colonies = args[:other_colonies] || []
    
    @population_size = args[:population_size] || POPULATION_SIZE_RANGE.min
    @life_cycles_number = args[:life_cycles_number] || LIFE_CYCLES_RANGE.min
    @evolution_steps = args[:evolution_steps] || EVOLUTION_STEPS_RANGE.min
    @task = args[:task] || DEFAULT_TASK
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
    { colony: main_colony, field: field, life_cycles: life_cycles }
  end
  
  def evolution_step(step)
    population = []
    @population_size.times do |population_number|
      population.push(get_person_for_population(step, population_number))
    end
    population.map { |person| person[:life_cycles] }
  end
  
  def evolve
    evolution = []
    @evolution_steps.times do |step|
      evolution.push(evolution_step(step))
    end
    evolution
  end
  
  private
  
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
