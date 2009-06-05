require 'redmine'

Redmine::Plugin.register :redmine_board_tagging do
  name 'Redmine Board Tagging plugin'
  author 'Masaki Takemori'
  description 'This is a plugin for Redmine'
  version '0.9.0'
end

Redmine::AccessControl.map do |map|
  map.project_module :boards do |map|
    map.permission :show_tag_items, {:boards => :tag}
    map.permission :add_tags, {:messages => :add_tags}
    map.permission :delete_tags, {:messages => :delete_tags}
  end
end