require 'rails_helper'

describe PlannerController do

  it "planner should redirect to sign in if not logged in" do
    get :index
    expect(response).to redirect_to(new_user_session_path)
  end

end

describe PlannerController do

  before { sign_in(user) }
  let!(:user) { create(:user) }

  it "should get planner" do
    get :index
    expect(response).to be_success
  end
end
