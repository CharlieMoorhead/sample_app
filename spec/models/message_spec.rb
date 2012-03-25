require 'spec_helper'

describe Message do

	before(:each) do
		@sender = Factory(:user)
		@recipient = Factory(:user, :username => Factory.next(:username), :email => Factory.next(:email))

		@attr = { :content => "foobar", :recipient_id => @recipient.id }
	end

	it "should create a message given valid attributes" do
		@sender.sent_messages.create!(@attr)
	end

	describe "validations" do

		it "should require a sender_id" do
			Message.new(@attr).should_not be_valid
		end

		it "should require a recipient_id" do
			@sender.sent_messages.build(@attr.merge( :recipient_id => nil )).should_not be_valid
		end

		it "should require content" do
			@sender.sent_messages.build(@attr.merge(:content => "")).should_not be_valid
		end

		it "should reject content that is too long" do
			@sender.sent_messages.build(@attr.merge(:content => "a" * 141)).should_not be_valid
		end
	end

	describe "user assocations" do

		before(:each) do
			@message = @sender.sent_messages.create!(@attr)
		end

		it "should have a sender attribute" do
			@message.should respond_to(:sender)
		end

		it "should have a recipient attribute" do
			@message.should respond_to(:recipient)
		end

		it "should have the right associated sender" do
			@message.sender_id.should == @sender.id
			@message.sender.should == @sender
		end

		it "should have the right associated recipient" do
			@message.recipient_id.should == @recipient.id
			@message.recipient.should == @recipient
		end
	end
end
