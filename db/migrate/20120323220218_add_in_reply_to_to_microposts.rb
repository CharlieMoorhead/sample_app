class AddInReplyToToMicroposts < ActiveRecord::Migration
  def self.up
    add_column :microposts, :in_reply_to, :integer
  end

  def self.down
    remove_column :microposts, :in_reply_to
  end
end
