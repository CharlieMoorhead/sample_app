namespace :db do
	desc "Fill database with sample data"
	task :populate => :environment do
		Rake::Task['db:reset'].invoke
		make_users
		make_microposts
		make_relationships
		make_messages
	end
end

def make_users
	admin = User.create!(:username => "ExampleUser",
					:name => "Example User",
					:email => "example@railstutorial.org",
					:password => "foobar",
					:password_confirmation => "foobar")
	admin.toggle!(:admin)
	User.create!(:username => "thechaz",
				 :name => "The Chaz",
				 :email => "chaz@chaz.chaz",
				 :password => "foobar",
				 :password_confirmation => "foobar")
	99.times do |n|
		name = Faker::Name.name
		username = name.gsub(/\s+/, "")
		email = "example-#{n+1}@railstutorial.org"
		password = "password"
		User.create!(:username => username,
					 	:name => name,
						:email => email,
						:password => password,
						:password_confirmation => password)
	end
end

def make_microposts
	50.times do
		User.all(:limit => 6).each do |user|
			user.microposts.create!(:content => Faker::Lorem.sentence(5))
		end
	end
end

def make_relationships
	users = User.all
	user = users.first
	following = users[1..50]
	followers = users[3..40]
	following.each { |followed| user.follow!(followed) }
	followers.each { |follower| follower.follow!(user) }
end

def make_messages
	20.times do
		User.all(:limit => 2).each do |sender|
			User.all(:limit => 2).each do |recipient|
				sender.sent_messages.create!(:content => "@#{recipient.username} " + Faker::Lorem.sentence(5),
											 :recipient_id => recipient.id) unless sender.id == recipient.id
			end
		end
	end
end
