class PagesController < ApplicationController
  def home
  end

  def test
    @field = Field.new "Test Field", 50, 50
  end
  
  def new_life
    colonies = [{ colony: Colony.new("John Dorian") }]
    field = Field.new "Test Field", 50, 50, colonies: colonies
    respond_to { |format| format.json { render json: field.get_life(cycles_number: 40) } }
  end
end
