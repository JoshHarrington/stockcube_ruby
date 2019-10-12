class CupboardMailerPreview < ActionMailer::Preview
	def sharing_cupboard_request_new_account
		sharing_email = "test@getstockcubes.com"
		requester = User.first
		hashids = Hashids.new(ENV['CUPBOARD_EMAIL_SHARE_ID_SALT'])
		encrypted_cupboard_id = hashids.encode(Cupboard.first.id)
		CupboardMailer.sharing_cupboard_request_new_account(sharing_email, requester, encrypted_cupboard_id)
	end
	def sharing_cupboard_request_existing_account
		sharing_email = "test@getstockcubes.com"
		requester = User.first
		hashids = Hashids.new(ENV['CUPBOARD_EMAIL_SHARE_ID_SALT'])
		encrypted_cupboard_id = hashids.encode(Cupboard.first.id)
		CupboardMailer.sharing_cupboard_request_existing_account(sharing_email, requester, encrypted_cupboard_id)
	end
end
