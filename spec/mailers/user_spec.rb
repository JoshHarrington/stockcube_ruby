require "rails_helper"

RSpec.describe UserMailer, :type => :mailer do
  describe "Notify admin when ingredient added" do
    let!(:user) { create(:user) }
    let!(:admin_user) { create(:user, admin: true) }
    let!(:ingredient) { create(:ingredient)}

    let(:mail) { UserMailer.admin_ingredient_add_notification(user, ingredient) }

    it "renders the headers" do
      expect(mail.subject).to eq("User added new ingredient")
      expect(mail.to).to eq([admin_user.email])
      expect(mail.from).to eq(["team@getstockcubes.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to include(user.name)
      expect(mail.body.encoded).to include(ingredient.name)
    end
  end
end
