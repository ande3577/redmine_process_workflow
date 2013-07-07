module ProcessWorkflowIssuesControllerPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      before_filter :build_step_from_params, :build_members_from_parameters, :build_actions_from_parameters, :only => [:update, :new, :create, :edit, :update_form]
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def build_step_from_params
    return true if !@issue.tracker.process_workflow or params[:process_step].nil?
    @issue.next_step = ProcessStep.where(:id => params[:process_step]).first
  end
  
  def build_members_from_parameters
    return true unless @issue.tracker.process_workflow
    
    if params[:role]
      for r in params[:role]
        @issue.set_process_member(r[0], r[1])
      end
    end
    
    true
  end
  
  def build_actions_from_parameters
    return true unless @issue.tracker.process_workflow
    if params[:process_fields] and params[:process_fields][:custom_field_values]
      for f in params[:process_fields][:custom_field_values]
        @issue.set_process_action(f[0], f[1])
      end
    end
  end
  
end

IssuesController.send(:include, ProcessWorkflowIssuesControllerPatch)