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
  end
end
