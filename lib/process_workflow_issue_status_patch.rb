module ProcessWorkflowIssueStatusPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_many :process_steps, :dependent => :destroy
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  private
  
end

IssueStatus.send(:include, ProcessWorkflowIssueStatusPatch)