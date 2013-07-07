class ProcessWorkflowHooks < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => 'issues/process_workflows_form', :layout => false
  render_on :view_issues_show_details_bottom, :partial => 'issues/process_workflows_details', :layout => false
end