module UsersHelper

	def gravatar_for(user, options = { :size => 50 })
		gravatar_image_tag(user.email.downcase, :alt => h(user.name),
						   						:class => 'gravatar',
						   						:gravatar => options)
	end

	def messages_user_path(user)
		"/users/#{user.id}/messages/"
	end

end
