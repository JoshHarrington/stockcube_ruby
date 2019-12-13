class CupboardInvitee < ApplicationRecord
	belongs_to :cupboard
	validates :email, presence: true
	validates :cupboard_id, presence: true
	validates :email, uniqueness: true
end
