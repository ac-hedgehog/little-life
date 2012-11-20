class Evolution < ActiveRecord::Base
  attr_accessible :evolution_steps, :field_cols, :field_name, :field_rows,
                  :life_cycles_number, :main_left, :main_name, :main_top,
                  :mutation_level, :population_size
  attr_accessor :main_colony, :field, :best_person
  
  ENEMY_NAME = "Budy Enemy"
  FIELD_SIZE_RANGE = (7..25)
  LIFE_CYCLES_RANGE = (10..25)
  POPULATION_SIZE_RANGE = (6..12)
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
    
    field_before = Field.new name: "Field Before", text_cells: life_cycles.first
    field_after = Field.new name: "Field After", text_cells: life_cycles.last
    task_points = self.task.calculate_points_for colony.name,
                                                 field_before,
                                                 field_after
    
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
    set_enemy_colony if self.task.is_absorption?
    self.evolution_steps.times do |step|
      evolution.push(evolution_step(step))
    end
    evolution
  end
  
  def self.evolve_to_hash(evolve)
    evolve.map { |population| population.map { |person|
      colony = person[:colony]
      { colony: { name: colony.name, cells: colony.cells },
        life_cycles: person[:life_cycles],
        task_points: person[:task_points],
        ids: person[:ids] }
    } }
  end
  
  private
  
  def set_enemy_colony
    enemy = Colony.where(name: ENEMY_NAME).first || Colony.new(name: ENEMY_NAME)
    @field.push_colonies [{ colony: enemy,
                            top: @field.rows - enemy.rows,
                            left: @field.cols - enemy.cols }]
  end
  
  def create_best_person_by(population)
    population.shuffle.max_by{ |person| person[:task_points] }.clone
  end
  
  def mutate_main_colony(colony_number)
    mutant = @main_colony.clone
    part_size = self.population_size / 3
    mutant.truncate_by @best_person[:ids] if colony_number >= part_size && @best_person
    case colony_number
    when 0, part_size
      mutant
    when 1..part_size - 1, part_size + 1..part_size * 2 - 1
      mutant.mutate self.mutation_level
    else
      Colony.new name: self.main_name
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
    
    @main_colony = Colony.find_by_name(self.main_name)
    @field = Field.new name: self.field_name, rows: self.field_rows, cols: self.field_cols
    @field.push_colonies [] # not main colonies
    
    self.task ||= Task.first || Task.create!
  end
end
