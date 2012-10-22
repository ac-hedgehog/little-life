class PagesController < ApplicationController
  def index
    @colony = Colony.new "Creature"
    @field = Field.new "Test Field", 9, 9
    @population_size = 5
    @evolution_steps = 4
  end
  
  def new_life
    evolution = Evolution.new field_rows: 9, field_cols: 9,
                              main_top: 2, main_left: 2,
                              evolution_steps: 4,
                              life_cycles_number: 15,
                              mutation_level: 2
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
  end
end
