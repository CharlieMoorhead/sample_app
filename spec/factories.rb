Factory.define :user do |user|
	user.username				"cmoorhead"
	user.name					"Charlie Moorhead"
	user.email					"cmoorhead@example.com"
	user.password				"foobar"
	user.password_confirmation	"foobar"
end

Factory.sequence :name do |n|
	"Person #{n}"
end

Factory.sequence :email do |n|
	"person-#{n}@example.com"
end

Factory.sequence :username do |n|
	"person-#{n}"
end

Factory.define :micropost do |micropost|
	micropost.content "Foo bar"
	micropost.association :user
end
