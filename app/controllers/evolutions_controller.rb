class EvolutionsController < ApplicationController
  def new
    @evolution = Evolution.new main_name: "My creature",
                               field_rows: 9, field_cols: 9,
                               main_top: 2, main_left: 2,
                               evolution_steps: 5,
                               mutation_level: 2
    @evolve = @evolution.evolve
  end
  
  def create
    evolution = Evolution.new(params[:evolution])
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
  end
end
