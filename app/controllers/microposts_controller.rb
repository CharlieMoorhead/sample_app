class MicropostsController < ApplicationController
	before_filter :authenticate, :only => [:create, :destroy]
	before_filter :authorized_user, :only => :destroy

	def create
		unless send_message(params[:micropost])
			post = make_reply(params[:micropost])
			@micropost = current_user.microposts.build(post)
			if @micropost.save
				flash[:success] = "Micropost created!"
				redirect_to root_path
			else
				@feed_items = []
				render 'pages/home'
			end
		end
	end

	def destroy
		@micropost.destroy
		redirect_back_or root_path
	end

	private

		def authorized_user
			@micropost = current_user.microposts.find_by_id(params[:id])
			redirect_to root_path if @micropost.nil?
		end

		def make_reply micropost_params
			replied_id = find_replied(micropost_params[:content])
			micropost_params.merge(:in_reply_to => replied_id)
		end

		def find_replied content
			if (replied = content.scan(/\A@\S+/).first)
				replied = replied[1..-1]
				if (replied_user = User.find(:first, :conditions => ["lower(username) = ?", replied.downcase]))
					replied_id = replied_user.id
				else
					nil
				end
			else
				nil
			end
		end

		def send_message micropost_params
			if (micropost_params[:content].scan(/\Ad@\S+/).first)
				content = micropost_params[:content][1..-1]
				recipient_id = find_replied(content)
				message = current_user.sent_messages.build(:content => content, :recipient_id => recipient_id)
				if message.save
					flash[:success] = "Message sent."
					redirect_to root_url(current_user)
					return true
				end
			end
		end
end
