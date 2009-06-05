class MessagesController < ApplicationController
  menu_item :boards
  before_filter :find_board, :only => [:new, :preview]
  before_filter :find_message, :except => [:new, :preview]
  before_filter :authorize, :except => [:preview, :edit, :destroy]

  verify :method => :post, :only => [ :reply, :destroy ], :redirect_to => { :action => :show }
  verify :xhr => true, :only => :quote

  helper :watchers
  helper :attachments
  include AttachmentsHelper
  
  before_filter :find_tags, :except => [:new, :preview]
  def add_tags
    if not params[:board_tag].nil?
      if not BoardTag.all(:conditions => {:name => params[:board_tag][:name]}).size > 0
        tag = BoardTag.new(params[:board_tag])
        tag.save
      else
        tag = BoardTag.first(:conditions => {:name => params[:board_tag][:name]})
      end
      if MessageToTag.all(:conditions => {:board_id => @topic.board_id, :message_id => @topic.id, :board_tag_id => tag.id}).empty?
        MessageToTag.create({
          :board_tag_id => tag.id,
          :message_id => @topic.id,
          :board_id => @topic.board_id
        })
        @tags << tag
      end
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'board_tags', :partial => 'messages/update_tags', :locals => {:tags => @tags, :topic => @topic}
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Tag added.', :layout => true
  end
  
  def delete_tags
    if not params[:board_tag].nil?
      if not BoardTag.all(:conditions => {:id => params[:board_tag][:id]}).size > 0
        tag = BoardTag.new
      else
        mtt = MessageToTag.first(:conditions => {:board_tag_id => params[:board_tag][:id], :message_id => @topic.id})
        tag = mtt.board_tag
        mtt.destroy
      end
      @tags.reject!{|t|t==tag}
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'board_tags', :partial => 'messages/update_tags', :locals => {:tags => @tags, :topic => @topic}
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Tag deleted.', :layout => true
  end
  
private
  def find_tags
    @tags = BoardTag.all(:conditions => ["message_to_tags.message_id = ?", @topic.id], :joins => :message_to_tags)
  end
end
MessagesController.unloadable
