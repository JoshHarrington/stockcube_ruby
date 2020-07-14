require 'rails_helper'

describe UnitsController do

  let!(:unit) { create(:unit)}

	it "should have the created factory unit" do
		expect(Unit.where(id: unit.id).length).to eq 1
	end

end
