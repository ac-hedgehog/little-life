class PagesController < ApplicationController
  def home
  end

  def test
    @field = Field.new "Test Field", 15, 15
  end
  
  def new_life
    evolution = Evolution.new field_rows: 15, field_cols: 15,
                              life_cycles_number: 15
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
    #colonies = [{ colony: Colony.new("John Dorian") }]
    #checkpoints = [{ type: :finish, coordinates: [14, 14] }]
    #field = Field.new "Test Field", 15, 15, checkpoints: checkpoints, colonies: colonies
    #respond_to { |format| format.json { render json: field.get_life } }
  end
end
