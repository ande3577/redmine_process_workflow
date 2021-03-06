require_dependency 'process_workflow_tracker_patch'
require_dependency 'process_workflow_issue_patch'
require_dependency 'process_workflow_issues_controller_patch'
require_dependency 'process_workflow_user_patch'
require_dependency 'process_workflow_custom_field_patch'
require_dependency 'process_workflow_issue_status_patch'
require_dependency 'process_workflow_hooks'
require_dependency 'process_workflow_issues_helper_patch'

Redmine::Plugin.register :redmine_process_workflow do
  menu :admin_menu, :redmine_process_workflow, { :controller => :process_workflows, :action => :index }, :caption => :processes
  project_module :issue_tracking do
    permission :set_process_step, :issues => :set_step
  end
  
  name 'Redmine Process Workflow plugin'
  author 'David S Anderson'
  description 'Add a process based workflow to redmine'
  version '0.0.1'
  url 'https://www.github.com/ande3577/redmine_process_workflow'
  author_url 'https://www.github.com/ande3577'
end
