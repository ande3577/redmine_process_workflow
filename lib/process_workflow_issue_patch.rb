module ProcessWorkflowIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def apply_process_step_change(step)
      return false if step.nil?
      
      state = ProcessState.where(:issue_id => self.id).first
      if state.nil?
        state = ProcessState.new(:issue => self, :process_step => step)
      else
        state.process_step = step 
      end
      return false unless state.save
      
      status = step.issue_status
      return save
    end
    
    def process_step
      state = ProcessState.where(:issue_id => self.id).first
      return nil if state.nil?
      
      state.process_step
    end
  end
  
  private
  
end

Issue.send(:include, ProcessWorkflowIssuePatch)