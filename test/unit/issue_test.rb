require File.expand_path('../../test_helper', __FILE__)

class IssueTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :time_entries
  
  def setup
    @tracker = Tracker.first
    @tracker.process_workflow = true
    @tracker.save
    
    @user = User.first
    @next_user = User.find(2)
    @status = IssueStatus.first
    @next_status = IssueStatus.find(2)
    
    @role = ProcessRole.new(:tracker => @tracker, :name => 'role_name')
    assert @role.save
    @next_role = ProcessRole.new(:tracker => @tracker, :name => 'next_role')
    assert @next_role.save
    
    @step = ProcessStep.new(:name => 'step', :issue_status => @status, :tracker => @tracker, :process_role_id => @role.id)
    assert @step.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float')
    assert @custom_field.save
    
    @field = ProcessField.new(:custom_field => @custom_field, :process_step => @step)
    assert @field.save
    
    @next_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker, :process_role_id => @next_role.id)
    assert @next_step.save
    
    @issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_create',
    :description => 'IssueTest#test_create', :estimated_hours => '1:30')
    
    assert @issue.save
    
    @member = ProcessMember.new(:process_role => @role, :user => @user, :issue => @issue)
    assert @member.save
    @next_member = ProcessMember.new(:process_role => @next_role, :user => @next_user, :issue => @issue)
    assert @next_member.save
    
    assert @issue.save
    
    @admin = User.where(:admin => true).first
  end
  
  def test_apply_step
    assert @issue.apply_process_step_change(@next_step)
    
    assert_equal @next_step, @issue.process_step
    assert_equal @next_status, @issue.status
    assert_equal @next_user, @issue.assigned_to
  end
  
  def test_apply_step_nil
    assert @issue.apply_process_step_change(nil)
    
    assert_equal @step, @issue.process_step
  end
  
  
  
  def test_apply_step_without_role
    @next_step.process_role = nil
    @next_step.save
    
    assert @issue.apply_process_step_change(@next_step)
        
    assert_equal @next_step, @issue.process_step
    assert_equal @next_status, @issue.status
    assert_equal @user, @issue.assigned_to
  end
  
  def test_apply_step_with_author
    @next_step.process_role_id = ProcessStep::AUTHOR
    assert @next_step.save
    
    assert @issue.apply_process_step_change(@next_step)
    
    assert_equal @issue.author_id, @issue.assigned_to_id
  end
  
  def test_create
    assert_equal @step, @issue.process_step
    assert_equal @status, @issue.status
    assert_equal @user, @issue.assigned_to
    
    assert @field.find_action(@issue)
  end
  
  def test_sort_steps
    @next_step.move_to_top
    @next_step.save
    
    new_issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_sort_steps',
    :description => 'IssueTest#test_sort_steps', :estimated_hours => '1:30')
    
    new_member = ProcessMember.new(:process_role => @next_role, :user => @next_user, :issue => new_issue)
    assert new_member.save
    
    assert new_issue.save
    new_issue.reload
    
    assert_equal @next_step, new_issue.process_step
    assert_equal @next_status, new_issue.status
    assert_equal @next_user, new_issue.assigned_to
  end
  
  def test_update_assign_when_changing_member
    @member.user = @next_user
    @member.save
    @issue.reload
    
    assert_equal @next_user, @issue.assigned_to
  end
  
  def test_update_assign_when_changing_role
    @step.process_role = @next_role
    @step.save
    @issue.reload
    
    assert_equal @next_user, @issue.assigned_to
  end
  
  def test_disable_assignee_if_process
    assert !@issue.safe_attribute?('assigned_to_id', @admin) 
  end
  
  def test_enable_assignee_if_not_process
    @tracker.process_workflow = false
    @tracker.save
    
    assert @issue.safe_attribute?('assigned_to_id', @admin) 
  end
  
  def test_disable_status_if_process
    assert !@issue.safe_attribute?('status_id', @admin)
  end
  
  def test_enable_status_if_not_process
    @tracker.process_workflow = false
    @tracker.save
        
    assert @issue.safe_attribute?('status_id', @admin) 
  end
  
end