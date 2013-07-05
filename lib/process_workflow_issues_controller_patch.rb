module ProcessWorkflowIssuesControllerPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      before_filter :find_step, :only => [:show, :update, :new, :create, :edit, :update_form]
      before_filter :initialize_members, :initialize_actions, :only => [:show, :update, :new, :create, :edit, :update_form]
      before_filter :find_members, :find_actions, :only => [:show, :update, :edit, :update_form]
      before_filter :build_members_from_parameters, :build_actions_from_parameters, :only => [:update, :new, :create, :edit, :update_form]
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  def find_step
    return true unless @issue.tracker.process_workflow

    if params[:process_step]
      @process_step = ProcessStep.where(:id => params[:process_step]).first
    end
    @process_step = @issue.process_step if @process_step.nil?
  end
  
  def initialize_members
    @process_members = Hash.new()    
  end
  
  def initialize_actions
    @process_actions = Hash.new()    
  end
  
  def find_members
    return true unless @issue.tracker.process_workflow
    for m in @issue.process_members
      @process_members[m.process_role.name] = m
    end
  end
  
  def find_actions
    return true unless @issue.tracker.process_workflow
    for a in @issue.process_actions
      @process_actions[a.process_field.custom_field.id.to_s] = a
    end
  end
  
  def build_members_from_parameters
    return true unless @issue.tracker.process_workflow
    
    if params[:role]
      for r in params[:role]
        @process_members[r[0]] = ProcessMember.new(:process_role => ProcessRole.where(:name => r[0]).first) if @process_members[r[0]].nil?
        @process_members[r[0]].user_id = r[1]
      end
    end
    
    true
  end
  
  def build_actions_from_parameters
    return true unless @issue.tracker.process_workflow
    
    if params[:process_fields] and params[:process_fields][:custom_field_values]
      for f in params[:process_fields][:custom_field_values]
        field = ProcessField.where(:custom_field_id => f[0]).first
        @process_actions[f[0]] = ProcessAction.new(:issue => @issue, :process_field_id => field.id) if field and @process_actions[f[0]].nil?
        @process_actions[f[0]].value = f[1]
        @process_actions[f[0]].user_id = User.current.id
        @process_actions[f[0]].timestamp = Time.now
      end
    end
  end
  
end

IssuesController.send(:include, ProcessWorkflowIssuesControllerPatch)