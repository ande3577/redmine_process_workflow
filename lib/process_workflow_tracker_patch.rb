module ProcessWorkflowTrackerPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_many :process_steps, :order => 'position ASC', :dependent => :destroy
      has_many :process_roles, :order => 'position ASC', :dependent => :destroy
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def process_workflow?
      return self.process_workflow
    end
  end
  
  private
  
end

Tracker.send(:include, ProcessWorkflowTrackerPatch)