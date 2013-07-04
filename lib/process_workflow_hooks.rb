class ProcessWorkflowHooks < Redmine::Hook::ViewListener
  render_on :view_issues_form_details_bottom, :partial => 'issues/process_workflows_form', :layout => false
  render_on :view_issues_show_details_bottom, :partial => 'issues/process_workflows_details', :layout => false
  
  def controller_issues_edit_after_save( context = { } )
    if context[:issue].tracker.process_workflow
      issue_update_roles(context[:issue], context[:params])
      if !issue_handle_step(context[:issue], context[:params])
        issue_handle_process_fields(context[:issue], context[:params])
      end
    end
  end
  
  def controller_issues_new_after_save( context = { } )
    if context[:issue].tracker.process_workflow
      issue_update_roles(context[:issue], context[:params])
      if !issue_handle_step(context[:issue], context[:params])
        issue_handle_process_fields(context[:issue], context[:params])
      end
    end
  end
  
  private
  def issue_update_roles(issue, params)
    unless params[:role].nil?
      params[:role].each do |r|
        role = ProcessRole.where(:tracker_id => issue.tracker, :name => r[0]).first
        unless role.nil?
          member = ProcessMember.where(:issue_id => issue, :process_role_id => role).first
          if member.nil?
            ProcessMember.create(:process_role_id => role.id, :issue_id => issue.id, :user_id => r[1])
          else
            member.user_id = r[1]
            member.save
          end
        end
      end
    end
  end
  
  def issue_handle_step(issue, params)
    step = ProcessStep.where(:id => params[:process_step]).first unless params[:process_step].nil?
    if !step.nil? && (step != issue.process_step) 
      issue.apply_process_step_change(step)
      return true
    end
    false
  end
  
  def issue_handle_process_fields(issue, params)
    custom_fields = params[:process_fields][:custom_field_values] unless params[:process_fields].nil?
    
    unless custom_fields.nil?
      custom_fields.each do |field|
        process_state = ProcessState.where(:issue_id => issue.id).first
        process_field = ProcessField.where(:process_step_id => process_state.process_step, :custom_field_id => field[0]).first
        process_action = ProcessAction.where(:issue_id => issue.id, :process_field_id => process_field.id).first
        process_action.value = field[1]
        process_action.user_id = User.current.id
        process_action.timestamp = Time.now
        process_action.save
        process_action.reload
        process_action.apply_action
      end
    end
  end
  
  
end