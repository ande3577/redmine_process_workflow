module ProcessWorkflowUserPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :remove_references_before_destroy, :process_actions
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  private
  
  def remove_references_before_destroy_with_process_actions
    return remove_references_before_destroy_without_process_actions if self.id.nil?
    remove_references_before_destroy_without_process_actions
    
    ProcessMember.destroy_all(:user_id => self.id)
    ProcessAction.update_all ['user_id = ?', User.anonymous.id], ['user_id = ?', id]
  end
  
end

User.send(:include, ProcessWorkflowUserPatch)