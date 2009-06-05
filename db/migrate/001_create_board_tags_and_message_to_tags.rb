class CreateBoardTagsAndMessageToTags < ActiveRecord::Migration
  def self.up
    create_table :board_tags do |t|
      t.column :name, :string, :default => '', :null => false
    end
    create_table :message_to_tags do |t|
      t.column :message_id, :integer, :default => 0, :null => false
      t.column :board_id, :integer, :default => 0, :null => false
      t.column :board_tag_id, :integer, :default => 0, :null => false
    end
  end

  def self.down
    drop_table :board_tags
    drop_table :message_to_tags
  end
end
