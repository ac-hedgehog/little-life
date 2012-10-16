class PagesController < ApplicationController
  def home
  end

  def test
    @field = Field.new "Test Field", 15, 15
  end
  
  def new_life
    #colonies = [{ colony: Colony.new("John Dorian") }]
    #field = Field.new "Test Field", 15, 15, colonies: colonies
    #respond_to { |format| format.json { render json: field.get_life(life_cycles_number: 20) } }
    evolution = Evolution.new field_rows: 15, field_cols: 15,
                              life_cycles_number: 15
    respond_to do |format|
      format.json { render json: evolution.evolve }
    end
  end
end
