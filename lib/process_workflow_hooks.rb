class ProcessWorkflowHooks < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => 'issues/process_workflows_form', :layout => false
  render_on :view_issues_show_details_bottom, :partial => 'issues/process_workflows_details', :layout => false
  render_on :view_issues_mailer_after_fields, :partial => 'mailer/issue_process_fields'
  
  def helper_issues_show_detail_after_setting(context)
    if context[:detail].property.eql?('process_role')
      # workaround to force the label to be properly drawn
      context[:detail].property = 'attr'
    end
  end
end