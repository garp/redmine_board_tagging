class MessageToTag < ActiveRecord::Base
  belongs_to :message
  belongs_to :board_tag
  belongs_to :board
end