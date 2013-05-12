require_dependency 'process_workflow_tracker_patch'
require_dependency 'process_workflow_issue_patch'

Redmine::Plugin.register :redmine_process_workflow do
  menu :admin_menu, :redmine_process_workflow, { :controller => :process_workflows, :action => :index }, :caption => :processes
  
  name 'Redmine Process Workflow plugin'
  author 'David S Anderson'
  description 'Add a process based workflow to redmine'
  version '0.0.1'
  url 'https://www.github.com/ande3577/redmine_process_workflow'
  author_url 'https://www.github.com/ande3577'
end
