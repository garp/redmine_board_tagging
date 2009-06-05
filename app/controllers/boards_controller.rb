class BoardsController < ApplicationController
  before_filter :find_project, :authorize

  helper :messages
  include MessagesHelper
  helper :sort
  include SortHelper
  helper :watchers
  include WatchersHelper
  
  before_filter :find_board_tags, :only => [:show, :tag]
 
  def tag
    sort_init 'updated_on', 'desc'
    sort_update	'created_on' => "#{Message.table_name}.created_on",
                'replies' => "#{Message.table_name}.replies_count",
                'updated_on' => "#{Message.table_name}.updated_on"
    selected = @mtts.select{|m|m.board_tag_id == params[:tag].to_i}
    @topics = selected.map{|m|m.message}.select{|m|m.parent_id == nil}
    @topic_count = @topics.size
    @topic_pages = Paginator.new self, @topic_count, per_page_option, params['page']
    @topics =  @board.topics.find :all, :order => ["#{Message.table_name}.sticky DESC", sort_clause].compact.join(', '),
                                  :include => [:author, {:last_reply => :author}],
                                  :limit  =>  @topic_pages.items_per_page,
                                  :offset =>  @topic_pages.current.offset,
                                  :conditions => @topics.size > 0 ? "id IN (#{selected.map{|m|m.message_id}.join(',')})" : "id = 0"
    render :action => 'show', :layout => !request.xhr?
  end
  
  verify :method => :post, :only => [ :destroy ], :redirect_to => { :action => :index }

private
  def find_board_tags
    @mtts = MessageToTag.all(:conditions => {:board_id => @board.id}, :joins => [:message, :board_tag])
    @board_tags = @mtts.map{|m|m.board_tag}.uniq
  end
end
BoardsController.unloadable