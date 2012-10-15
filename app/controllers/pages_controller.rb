class PagesController < ApplicationController
  def home
  end

  def test
    @field = Field.new "Test Field", 15, 15
  end
  
  def new_life
    colonies = [{ colony: Colony.new("John Dorian") }]
    checkpoints = [{ type: :finish, coordinates: [14, 14] }]
    field = Field.new "Test Field", 15, 15, checkpoints: checkpoints, colonies: colonies
    respond_to { |format| format.json { render json: field.get_life } }
  end
end
