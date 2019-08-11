class UnitsController < ApplicationController
	def show
		@unit = Unit.find(params[:id])
	end
	private
		def unit_params
			params.require(:unit).permit(:id, :unit_type)
		end
end
