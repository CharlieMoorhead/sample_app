class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.string :content

      t.timestamps
    end
    add_index :messages, :recipient_id
  end

  def self.down
    drop_table :messages
  end
end
