class Micropost < ActiveRecord::Base
	attr_accessible :content, :in_reply_to

	belongs_to :user

	validates :content, :presence => true, :length => { :maximum => 140 }
	validates :user_id, :presence => true

	default_scope :order => 'microposts.created_at DESC'

	# Return microposts from the users being followed by the given user.
	scope :from_users_followed_by, lambda { |user| followed_by(user) }

	scope :from_replies, lambda { |user| replies(user) }

	def reply?
		in_reply_to
	end

	private

		# Return an SQL condition for users followed by the given user.
		def self.followed_by(user)
			following_ids = %(SELECT followed_id FROM relationships
							  WHERE follower_id = :user_id)
			where("user_id IN (#{following_ids})", { :user_id => user })
		end

		def self.replies(user)
			reply_ids = %(SELECT id FROM microposts)
			where("in_reply_to = :user_id OR user_id = :user_id", {:user_id => user})
		end

end
