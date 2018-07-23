class CupboardMailer < ApplicationMailer

	def sharing_cupboard_request(sharing_email, requester, encrypted_cupboard_id)
    @sharing_email = sharing_email
		@requester = requester
		@encrypted_cupboard_id = encrypted_cupboard_id
    mail to: sharing_email, subject: "Stockcubes - Cupboard sharing request"
  end

end
