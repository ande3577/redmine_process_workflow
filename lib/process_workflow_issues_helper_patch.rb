module ProcessWorkflowIssuesHelperPatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :render_issue_subject_with_tree, :process_status
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
  
  private
  
  def render_issue_subject_with_tree_with_process_status(issue)
    s = render_issue_subject_with_tree_without_process_status(issue)
    if issue.tracker.process_workflow? && issue.process_step && !issue.closed?
        if issue.assigned_to
          s << ("<em>" + l(:label_process_current_step_by, :user => issue.assigned_to, :step => issue.process_step.name) + "</em>").html_safe
        else
          s << ("<em>" + l(:label_process_current_step, :step => issue.process_step.name) + "</em>").html_safe
        end
    end 
    s
  end
  
end

IssuesHelper.send(:include, ProcessWorkflowIssuesHelperPatch)