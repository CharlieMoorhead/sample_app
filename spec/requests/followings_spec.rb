require 'spec_helper'

describe "Followings" do

	before(:each) do
		@user = Factory(:user)
		@followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
		visit signin_path
		fill_in :username, :with => @user.username
		fill_in :password, :with => @user.password
		click_button
	end

	describe "follow form" do

		it "should follow a user" do
			lambda do
				visit user_path(@followed)
				click_button
				response.should have_selector("input", :value => "Unfollow")
				response.should have_selector("a", :href => followers_user_path(@followed), :content => "1 follower")
				response.should have_selector("a", :href => following_user_path(@followed), :content => "0 following")
			end.should change(Relationship, :count).by(1)
		end

		it "should unfollow a user" do
			@user.follow!(@followed)
			lambda do
				visit user_path(@followed)
				click_button
				response.should have_selector("input", :value => "Follow")
				response.should have_selector("a", :href => followers_user_path(@followed), :content => "0 followers")
				response.should have_selector("a", :href => following_user_path(@followed), :content => "0 following")
			end.should change(Relationship, :count).by(-1)
		end
	end
end
