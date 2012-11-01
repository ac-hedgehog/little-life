class Evolution
  LIFE_CYCLES_RANGE = (10..100)
  POPULATION_SIZE_RANGE = (5..20)
  EVOLUTION_STEPS_RANGE = (3..20)
  MUTATION_LEVELS = (1..10)
  
  def initialize(args = { })
    @field_rows, @field_cols = (args[:field_rows] || 15).to_i, (args[:field_cols] || 15).to_i
    
    @main_colony = args[:main_colony]
    @main_colony_name = args[:main_colony_name].blank? ? "Creature" : args[:main_colony_name]
    @main_colony.name = @main_colony_name if @main_colony
    
    @main_top, @main_left = (args[:main_top] || 0).to_i, (args[:main_left] || 0).to_i
    @other_colonies = args[:other_colonies] || []
    
    @life_cycles_number = (args[:life_cycles_number] || LIFE_CYCLES_RANGE.min).to_i
    @population_size = (args[:population_size] || POPULATION_SIZE_RANGE.min).to_i
    @evolution_steps = (args[:evolution_steps] || EVOLUTION_STEPS_RANGE.min).to_i
    
    @mutation_level = (args[:mutation_level] || MUTATION_LEVELS.min).to_i
    
    @task = Task.new(args[:task])
    self
  end
  
  def get_person_for_population(step, colony_number)
    colony = get_colony_for_evolution_step(step, colony_number).clone
    all_colonies = @other_colonies.clone
    all_colonies.push({ colony: colony, top: @main_top, left: @main_left })
    field = Field.new name: "Evolution Field",
                      rows: @field_rows, cols: @field_cols
    field.push_colonies all_colonies
    field_clone = field.clone
    life_cycles = field_clone.get_life life_cycles_number: @life_cycles_number
    colony_after = Colony.new name: @main_colony_name, cells: life_cycles.last
    task_points = @task.calculate_points_for colony, colony_after
    { colony: colony.clone, life_cycles: life_cycles }.merge(task_points)
  end
  
  def evolution_step(step)
    population = []
    @population_size.times do |colony_number|
      population.push(get_person_for_population(step, colony_number))
    end
    create_best_person_by population
    @main_colony = @best_person[:colony].clone
    population
  end
  
  def evolve
    evolution = []
    @evolution_steps.times do |step|
      evolution.push(evolution_step(step))
    end
    evolution
  end
  
  private
  
  def create_best_person_by(population)
    @best_person = population.shuffle.max_by{ |person| person[:task_points] }.clone
  end
  
  def mutate_main_colony(colony_number)
    mutant = @main_colony.clone
    second_part_number = @population_size / 2
    mutant.truncate_by @best_person[:ids] if colony_number >= second_part_number
    case colony_number
    when 0, second_part_number
      mutant
    else
      mutant.mutate @mutation_level
    end
  end
  
  def get_colony_for_evolution_step(step, colony_number)
    if step == 0 && @main_colony.nil?
      Colony.new name: @main_colony_name
    else
      mutate_main_colony(colony_number).clone
    end
  end
end
