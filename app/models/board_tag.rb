class BoardTag < ActiveRecord::Base
  has_many :message_to_tags
  has_many :messages, :through => :message_to_tags
end