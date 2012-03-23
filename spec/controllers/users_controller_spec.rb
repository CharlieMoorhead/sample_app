require 'spec_helper'

describe UsersController do
	render_views

	describe "GET 'index'" do
 
		describe "for non-signed in users" do
			it "should deny access" do
				get :index
				response.should redirect_to(signin_path)
				flash[:notice].should =~ /sign in/i
			end
		end

		describe "for non-admin users" do

			before(:each) do
				@user = test_sign_in (Factory(:user))
				@users = [@user]

				50.times do
					@users << Factory(:user, :username => Factory.next(:username), :name => Factory.next(:name), :email => Factory.next(:email))
				end
			end

			it "should be successful" do
				get :index
				response.should be_success
			end

			it "should have the right title" do
				get :index
				response.should have_selector("title", :content => "All users")
			end

			it "should have an element for each user" do
				get :index
				@users[0..5].each do |user|
					response.should have_selector("li", :content => user.username)
				end
			end

			it "should not have a delete option for users" do
				get :index
				response.should_not have_selector("li", :content => "delete")
			end

			it "should paginate users" do
				get :index
				response.should have_selector("div.pagination")
				response.should have_selector("span.disabled", :content => "Previous")
				response.should have_selector("a", :href => "/users?page=2", :content => "2")
				response.should have_selector("a", :href => "/users?page=2", :content => "Next")
			end
		end

		describe "for admin users" do

			before(:each) do
				admin = Factory(:user, :username => "adminUser", :email => "admin@example.com", :admin => true)
				test_sign_in(admin)
			end

			it "should have a delete option for users" do
				get :index
				response.should have_selector("li", :content => "delete")
			end
		end
	end

	describe "GET 'show'" do

		before(:each) do
			@user = Factory(:user)
		end

		it "should be successful" do
			get :show, :id => @user
			response.should be_success
		end

		it "should find the right user" do
			get :show, :id => @user
			assigns(:user).should == @user
		end

		it "should have the right title" do
			get :show, :id => @user
			response.should have_selector("title", :content => @user.name)
		end

		it "should include the user's name" do
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.name)
		end

		it "should include the user's username" do
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.username)
		end

		it "should have a profile image" do
			get :show, :id => @user
			response.should have_selector("h1>img", :class => "gravatar")
		end

		it "should show the user's microposts" do
			mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
			mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
			get :show, :id => @user
			response.should have_selector("span.content", :content => mp1.content)
			response.should have_selector("span.content", :content => mp2.content)
		end
		
		it "should have the right follower/following counts" do
			followed = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
			@user.follow!(followed)
			get :show, :id => @user
			response.should have_selector("a", :href => following_user_path(@user), :content => "1 following")
			response.should have_selector("a", :href => followers_user_path(@user), :content => "0 followers")
		end
	end

	describe "Get 'new'" do

		it "should be successful" do
			get :new
			response.should be_success
		end

		it "should have the right title" do
			get :new
			response.should have_selector("title", :content => "Sign up")
		end

		it "should have a username field" do
			get :new
			response.should have_selector("input[name='user[username]'][type='text']")
		end

		it "should have a name field" do
			get :new
			response.should have_selector("input[name='user[name]'][type='text']")
		end

		it "should have an email field" do
			get :new
			response.should have_selector("input[name='user[email]'][type='text']")
		end

		it "should have a password field" do
			get :new
			response.should have_selector("input[name='user[password]'][type='password']")
		end

		it "should have a password confirmation field" do
			get :new
			response.should have_selector("input[name='user[password_confirmation]'][type='password']")
		end

		describe "for signed-in user" do

			before(:each) do
				@user = Factory(:user)
				test_sign_in(@user)
			end

			it "should redirect to the root url" do
				get :new
				response.should redirect_to(root_url)
			end
		end
	end

	describe "POST 'create'" do

		describe "for signed-in users" do

			before(:each) do
				@attr = { :username => "NewUser", :name => "New User", :email => "user@example.com",
							:password => "foobar", :password_confirmation => "foobar" }
				@user = Factory(:user)
				test_sign_in(@user)
			end

			it "should redirect to the root url" do
				post :create, :user => @attr
				response.should redirect_to(root_url)
			end
		end

		describe "failure" do

			before(:each) do
				@attr = { :username => "", :name => "", :email => "", :password => "", :password_confirmation => "" }
			end

			it "should not create a user" do
				lambda do
					post :create, :user => @attr
				end.should_not change(User, :count)
			end

			it "should have the right title" do
				post :create, :user => @attr
				response.should have_selector("title", :content => "Sign up")
			end

			it "should render the 'new' page" do
				post :create, :user => @attr
				response.should render_template('new')
			end
		end

		describe "success" do

			before(:each) do
				@attr = { :username => "NewUser", :name => "New User", :email => "user@example.com",
							:password => "foobar", :password_confirmation => "foobar" }
			end

			it "should create a user" do
				lambda do
					post :create, :user => @attr
				end.should change(User, :count).by(1)
			end

			it "should redirect to the home page" do
				post :create, :user => @attr
				response.should redirect_to(root_url)
			end

			it "should have a welcome message" do
				post :create, :user => @attr
				flash[:success].should =~ /welcome to the sample app/i
			end

			it "should sign the user in" do
				post :create, :user => @attr
				controller.should be_signed_in
			end
		end
	end

	describe "GET 'edit'" do

		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end

		it "should be successful" do
			get :edit, :id => @user
			response.should be_success
		end

		it "should be successful" do
			get :edit, :id => @user
			response.should have_selector("title", :content => "Edit user")
		end

		it "should have a link to change the Gravatar" do
			get :edit, :id => @user
			gravatar_url = "http://gravatar.com/emails"
			response.should have_selector("a", :href => gravatar_url, :content => "change")
		end
	end

	describe "PUT 'update'" do

		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end

		describe "failure" do

			before(:each) do
				@attr = { :username => "", :email => "", :name => "", :password => "", :password_confirmation => "" }
			end

			it "should render the 'edit' page" do
				put :update, :id => @user, :user => @attr
				response.should render_template('edit')
			end

			it "should have the right title" do
				put :update, :id => @user, :user => @attr
				response.should have_selector("title", :content => "Edit user")
			end
		end

		describe "success" do

			before(:each) do
				@attr = { :username => "NewUser", :name => "New Name", :email => "user@example.org", :password=> "barbaz", :password_confirmation => "barbaz" }
			end

			it "should change the user's attributes" do
				put :update, :id => @user, :user => @attr
				@user.reload
				@user.username.should == @attr[:username]
				@user.name.should == @attr[:name]
				@user.email.should == @attr[:email]
			end

			it "should redirect to the user show page" do
				put :update, :id => @user, :user => @attr
				response.should redirect_to(user_path(@user))
			end

			it "should have a flash message" do
				put :update, :id => @user, :user => @attr
				flash[:success].should =~ /updated/
			end
		end
	end

	describe "authentication of edit/update pages" do

		before(:each) do
			@user = Factory(:user)
		end

		describe "for non-signed-in users" do

			it "should deny access to 'edit'" do
				get :edit, :id => @user
				response.should redirect_to(signin_path)
			end

			it "should deny access to 'update'" do
				put :update, :id => @user, :user => {}
				response.should redirect_to(signin_path)
			end
		end

		describe "for signed-in users" do

			before(:each) do
				wrong_user = Factory(:user, :username => "wronguser", :email => "user@example.net")
				test_sign_in(wrong_user)
			end

			it "should require matching users for 'edit'" do
				get :edit, :id => @user
				response.should redirect_to(root_path)
			end

			it "should require matching users for 'update'" do
				put :update, :id => @user, :user => {}
				response.should redirect_to(root_path)
			end
		end
	end

	describe "DELETE 'destroy'" do

		before(:each) do
			@user = Factory(:user)
		end

		describe "as a non-signed-in user" do
			it "should deny access" do
				delete :destroy, :id => @user
				response.should redirect_to(signin_path)
			end
		end

		describe "as a non-admin user" do
			it "should protect the page" do
				test_sign_in(@user)
				delete :destroy, :id => @user
				response.should redirect_to(root_path)
			end
		end

		describe "as an admin user" do

			before(:each) do
				@admin = Factory(:user, :username => "adminuser", :email => "admin@example.com", :admin => true)
				test_sign_in(@admin)
			end

			it "should destroy the user" do
				lambda do
					delete :destroy, :id => @user
				end.should change(User, :count).by(-1)
			end

			it "should redirect to the users page" do
				delete :destroy, :id => @user
				response.should redirect_to(users_path)
			end

			it "should not let the admin destroy itself" do
				lambda do
					delete :destroy, :id => @admin
				end.should change(User, :count).by(0)
				response.should redirect_to(users_path)
			end
		end
	end

	describe "follow pages" do

		describe "when not signed in" do

			it "should protect 'following'" do
				get :following, :id => 1
				response.should redirect_to(signin_path)
			end

			it "should protect 'followers'" do
				get :following, :id => 1
				response.should redirect_to(signin_path)
			end
		end

		describe "when signed in" do

			before(:each) do
				@user = test_sign_in(Factory(:user))
				@other_user = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))
				@user.follow!(@other_user)
			end

			it "should show the user following" do
				get :following, :id => @user
				response.should have_selector("a", :href => user_path(@other_user), :content => @other_user.name)
			end

			it "should show the user followers" do
				get :followers, :id => @other_user
				response.should have_selector("a", :href => user_path(@user), :content => @user.name)
			end
		end
	end
end
