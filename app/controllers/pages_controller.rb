class PagesController < ApplicationController
  def index
    @colony = Colony.new name: "Creature"
    @field = Field.new name: "Test Field", rows: 9, cols: 9
    @evolution_steps = 5
    @population_size = 5
  end
  
  def new_life
    evolution_params = { main_colony_name: "Creature",
                         field_rows: 9, field_cols: 9,
                         main_top: 2, main_left: 2,
                         evolution_steps: 5,
                         population_size: 5,
                         life_cycles_number: 15,
                         mutation_level: 2 }.merge(params[:evolution].symbolize_keys)
    evolution = Evolution.new(evolution_params)
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
  end
end
