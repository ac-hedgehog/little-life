class PagesController < ApplicationController
  def index
    @colony = Colony.new "Creature"
    @field = Field.new "Test Field", 10, 10
    @population_size = 5
    @evolution_steps = 3
  end
  
  def new_life
    evolution = Evolution.new field_rows: 10, field_cols: 10,
                              life_cycles_number: 15
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
  end
end
