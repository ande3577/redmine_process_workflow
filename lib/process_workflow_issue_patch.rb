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
      status = step.issue_status
      printf "\nNew status = #{step.issue_status.to_s}\n"
      return save
    end
  end
  
  private
  
end

Issue.send(:include, ProcessWorkflowIssuePatch)