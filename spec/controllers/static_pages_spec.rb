require 'rails_helper'

describe StaticPagesController do

  it "should not have a current_user" do
    # note the fact that you should remove the "validate_session" parameter if this was a scaffold-generated controller
    expect(subject.current_user).to eq(nil)
  end

  it "should get index" do
    get :home
    expect(response).to be_success
  end
end
