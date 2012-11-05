class ColoniesController < ApplicationController
  def create
    attrs = { name: params[:colony][:name],
              rows: params[:colony][:rows],
              cols: params[:colony][:cols],
              text_cells: params[:colony][:cells] }
    colony = Colony.find_by_name(attrs[:name])
    success = colony ? colony.update_attributes(attrs) : Colony.new(attrs).save
    respond_to do |format|
      format.json { render json: { success: success }.to_json }
    end
  end
end
