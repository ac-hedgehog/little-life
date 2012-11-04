class Evolution < ActiveRecord::Base
  attr_accessible :evolution_steps, :field_cols, :field_name, :field_rows,
                  :life_cycles_number, :main_left, :main_name, :main_top,
                  :mutation_level, :population_size
  attr_accessor :main_colony, :field, :best_person

  FIELD_SIZE_RANGE = (7..25)
  LIFE_CYCLES_RANGE = (10..25)
  POPULATION_SIZE_RANGE = (5..10)
  EVOLUTION_STEPS_RANGE = (3..9)
  MUTATION_LEVELS = (1..10)

  has_one :task

  after_initialize :set_defaults
  
  def get_person_for_population(step, colony_number)
    colony = get_colony_for_evolution_step(step, colony_number).clone
    field_clone = @field.clone
    field_clone.push_colonies [{ colony: colony,
                                 top: self.main_top,
                                 left: self.main_left }]
    life_cycles = field_clone.get_life self.life_cycles_number
    colony_after = Colony.new name: self.main_name, cells: life_cycles.last
    task_points = self.task.calculate_points_for colony, colony_after
    { colony: colony.clone, life_cycles: life_cycles }.merge(task_points)
  end
  
  def evolution_step(step)
    population = []
    self.population_size.times do |colony_number|
      population.push(get_person_for_population(step, colony_number))
    end
    @best_person = create_best_person_by population
    @main_colony = @best_person[:colony].clone
    population
  end
  
  def evolve
    evolution = []
    self.evolution_steps.times do |step|
      evolution.push(evolution_step(step))
    end
    evolution
  end
  
  private
  
  def create_best_person_by(population)
    population.shuffle.max_by{ |person| person[:task_points] }.clone
  end
  
  def mutate_main_colony(colony_number)
    mutant = @main_colony.clone
    second_part_number = self.population_size / 2
    mutant.truncate_by @best_person[:ids] if colony_number >= second_part_number
    case colony_number
    when 0, second_part_number
      mutant
    else
      mutant.mutate self.mutation_level
    end
  end
  
  def get_colony_for_evolution_step(step, colony_number)
    if step == 0 && @main_colony.nil?
      Colony.new name: self.main_name
    else
      mutate_main_colony(colony_number).clone
    end
  end
  
  def set_defaults
    self.field_rows ||= FIELD_SIZE_RANGE.min
    self.field_cols ||= FIELD_SIZE_RANGE.min
    
    self.life_cycles_number ||= LIFE_CYCLES_RANGE.min
    self.population_size ||= POPULATION_SIZE_RANGE.min
    self.evolution_steps ||= EVOLUTION_STEPS_RANGE.min
    
    self.mutation_level ||= MUTATION_LEVELS.min
    
    @main_colony = nil
    @field = Field.new name: self.field_name, rows: self.field_rows, cols: self.field_cols
    @field.push_colonies [] # not main colonies
    
    self.task ||= Task.first
  end
end
