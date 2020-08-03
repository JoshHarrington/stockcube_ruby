require 'rails_helper'

describe CupboardsController do
	let!(:user) { create(:user) }
  before do
    user.confirm
    sign_in(user)
  end

  it "should get cupboards" do
    get :index
    expect(response).to be_success
  end
end