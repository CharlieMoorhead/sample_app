# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'digest'
class User < ActiveRecord::Base
	attr_accessor :password
	attr_accessible :username, :name, :email, :password, :password_confirmation

	has_many :microposts, :dependent => :destroy
	has_many :relationships, :foreign_key => "follower_id", :dependent => :destroy
	has_many :following, :through => :relationships, :source => :followed
	has_many :reverse_relationships, :foreign_key => "followed_id", :class_name => "Relationship", :dependent => :destroy
	has_many :followers, :through => :reverse_relationships, :source => :follower
	has_many :sent_messages, :foreign_key => "sender_id", :class_name => "Message", :dependent => :destroy
	has_many :received_messages, :foreign_key => "recipient_id", :class_name => "Message", :dependent => :destroy

	email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

	validates :username, :presence => true,
						:length => { :maximum => 50},
						:uniqueness => { :case_sensitive => false }
	validates :name, :presence => true,
						:length	=> { :maximum => 50 }
	validates :email, :presence => true,
						:format => { :with => email_regex },
						:uniqueness => { :case_sensitive => false }
	validates :password, :presence => true,
							:confirmation => true,
							:length => { :within => 6..40 }

	before_save :encrypt_password

	# Return true if the user's password matches the submitted password.
	def has_password?(submitted_password)
		encrypted_password == encrypt(submitted_password)
	end

	def self.authenticate(username, submitted_password)
		user = find(:first, :conditions => [ "lower(username) = ?", username.downcase])
		return nil if user.nil?
		return user if user.has_password?(submitted_password)
	end

	def self.authenticate_with_salt(id, cookie_salt)
		user = find_by_id(id)
		(user && user.salt == cookie_salt) ? user : nil
	end

	def following?(followed)
		relationships.find_by_followed_id(followed)
	end

	def follow!(followed)
		relationships.create!(:followed_id => followed.id)
	end

	def unfollow!(followed)
		relationships.find_by_followed_id(followed).destroy
	end

	def feed
		posts = Micropost.from_users_followed_by(self).where(:in_reply_to => nil) | Micropost.from_replies(self)
		posts.sort { |a,b| b.created_at <=> a.created_at }
	end

	private

		def encrypt_password
			self.salt = make_salt unless has_password?(password)
			self.encrypted_password = encrypt(password)
		end

		def encrypt(string)
			secure_hash("#{salt}--#{string}")
		end
		
		def make_salt
			secure_hash("#{Time.now.utc}--#{password}")
		end

		def secure_hash(string)
			Digest::SHA2.hexdigest(string)
		end
end
