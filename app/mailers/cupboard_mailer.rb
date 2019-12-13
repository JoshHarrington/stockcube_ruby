class CupboardMailer < ApplicationMailer
  helper :application

	def sharing_cupboard_request_new_account(sharing_email, requester, encrypted_cupboard_id)
    @sharing_email = sharing_email
		@requester = requester
		@encrypted_cupboard_id = encrypted_cupboard_id
    mail to: sharing_email, subject: "Stockcubes - Cupboard sharing request"
  end

	def sharing_cupboard_request_existing_account(sharing_email, requester, encrypted_cupboard_id)
    @requester = requester
		@encrypted_cupboard_id = encrypted_cupboard_id
    mail to: sharing_email, subject: "Stockcubes - Cupboard sharing request"
  end

end
