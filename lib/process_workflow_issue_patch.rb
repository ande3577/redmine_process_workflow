module ProcessWorkflowIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_one :process_state
      after_create :init_process
      after_create :create_actions
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def apply_process_step_change(step)
      return false if step.nil?
      
      state = self.process_state
      if state.nil?
        state = ProcessState.new(:issue => self, :process_step => step)
      else
        state.process_step = step 
      end
      return false unless state.save
      
      self.status = step.issue_status
      next_member = ProcessMember.where(:issue_id => self.id, :process_role_id => step.process_role_id).first unless step.process_role.nil?
      next_assignee = next_member.user unless next_member.nil?
      self.assigned_to = next_assignee unless next_assignee.nil?
      return save
    end
    
    def process_step
      state = self.process_state
      return nil if state.nil?
      
      state.process_step
    end
    
    def create_actions
      if tracker.process_workflow
        ProcessStep.where(:tracker_id => tracker.id).each do |step|
          step.process_fields.each do |field|
            ProcessAction.create(:issue_id => self.id, :process_field_id => field.id)
          end
        end
        
      end
    end
  end
  
  private
  
  def init_process
    if self.tracker.process_workflow?
      apply_process_step_change(self.tracker.process_steps.first)
    end
  end
  
end

Issue.send(:include, ProcessWorkflowIssuePatch)