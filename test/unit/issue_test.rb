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
    @virtual_role = ProcessRole.new(:tracker => @tracker, :name => 'virtual_role')
    assert @virtual_role.save
    
    @step = ProcessStep.new(:name => 'step', :issue_status => @status, :tracker => @tracker, :process_role_id => @role.id)
    assert @step.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float', :process_step => @step, :default_value => "1.234")
    assert @custom_field.save
    
    @field = @custom_field.process_field
    
    @next_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker, :process_role_id => @next_role.id)
    assert @next_step.save
    
    @issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_create',
    :description => 'IssueTest#test_create', :estimated_hours => '1:30')
    
    @issue.set_process_member(@role.name, @user.id)
    @issue.set_process_member(@next_role.name, @next_user.id)

    assert @issue.save
    
    @member = ProcessMember.where(:process_role_id => @role.id, :issue_id => @issue.id).first
    assert @member
    @next_member = ProcessMember.where(:process_role_id => @next_role.id, :issue_id => @issue.id).first
    assert @next_member
    
    assert @issue.save
    @issue.reload
    
    @group = Group.first
    
    @admin = User.where(:admin => true).first
  end
  
  def test_apply_step
    assert @issue.apply_process_step_change(@next_step)
    assert @issue.save
    @issue.reload
    
    assert_equal @next_step, @issue.process_step
    assert_equal @next_status, @issue.status
    assert_equal @next_user, @issue.assigned_to
  end
  
  def test_set_next_step
    @issue.next_step = @next_step
    assert @issue.save
    @issue.reload
    
    assert_equal @next_step, @issue.process_step
    
    state = ProcessState.where(:issue_id => @issue.id).first
    assert state
    assert_equal @next_step, state.process_step
  end
  
  def test_apply_step_with_group
    @issue.set_process_member(@next_role.name, @group.id)
    assert @issue.save
    @issue.reload
    
    @next_member.reload
    assert_equal @group, @next_member.principal
    
    assert @issue.apply_process_step_change(@next_step)
    assert @issue.save
    @issue.reload
    
    assert_equal @next_step, @issue.process_step
    assert_equal @next_status, @issue.status
    assert_equal @group, @issue.assigned_to
  end
  
  def test_apply_step_nil
    assert @issue.apply_process_step_change(nil)
    assert @issue.save
    @issue.reload
    
    assert_equal @step, @issue.process_step
  end
  
  def test_apply_step_without_role
    @next_step.process_role = nil
    @next_step.save
    
    assert @issue.apply_process_step_change(@next_step)
    assert @issue.save
    @issue.reload
        
    assert_equal @next_step, @issue.process_step
    assert_equal @next_status, @issue.status
    assert_equal @user, @issue.assigned_to
  end
  
  def test_apply_step_with_author
    @next_step.process_role_id = ProcessStep::AUTHOR
    assert @next_step.save
    
    assert @issue.apply_process_step_change(@next_step)
    assert @issue.save
    @issue.reload
    
    assert_equal @issue.author_id, @issue.assigned_to_id
  end
  
  def test_create
    assert_equal @step, @issue.process_step
    assert_equal @status, @issue.status
    assert_equal @user, @issue.assigned_to
    
    assert_equal nil, @issue.next_step
    assert_equal @member, @issue.process_member_list[@role.name]
      
    assert_equal @user, @member.principal
    assert_equal @next_user, @next_member.principal
    
    state = ProcessState.where(:issue_id => @issue.id).first
    assert state
    assert_equal @step, state.process_step
  end
  
  def test_missing_required_step_fields
    @custom_field.is_required = true
    assert @custom_field.save
    
    @issue.process_step.reload
    assert !@issue.save
  end
  
  def test_validate_required_step_fields
    @custom_field.is_required = true
    assert @custom_field.save
    
    @issue.process_step.reload

    @issue.process_field_actions[@custom_field.id.to_s] = ProcessAction.new(:process_field => @field, :issue => @issue, :value => "value")
    assert @issue.save
  end
  
  def test_missing_required_roles
    @role.is_required = true
    assert @role.save
    
    @issue.set_process_member(@role.name, '')
    assert !@issue.save
  end
  
  def test_validate_required_roles
    @role.is_required = true
    assert @role.save
    
    assert @issue.save
  end
  
  def test_sort_steps
    @next_step.move_to_top
    @next_step.save
    
    new_issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_sort_steps',
    :description => 'IssueTest#test_sort_steps', :estimated_hours => '1:30')
    
    new_member = ProcessMember.new(:process_role => @next_role, :principal => @next_user, :issue => new_issue)
    assert new_member.save
    
    assert new_issue.save
    new_issue.reload
    
    assert_equal @next_step, new_issue.process_step
    assert_equal @next_status, new_issue.status
    assert_equal @next_user, new_issue.assigned_to
  end
  
  def test_update_assign_when_changing_member
    @member.principal = @next_user
    @member.save
    @issue.reload
    
    assert_equal @next_user, @issue.assigned_to
  end
  
  def test_update_assigned_when_changing_to_group
    @member.principal = @group
    @member.save
    @issue.reload
    
    assert_equal @group, @issue.assigned_to
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
  
  def test_get_process_member
    assert_equal @member, @issue.get_process_member(@role.name)
  end
  
  def test_get_new_member
    member = @issue.get_process_member('virtual_role')
    assert member
    assert_equal @issue, member.issue
    assert_equal @virtual_role, member.process_role
    assert_equal nil, member.principal
  end
  
  def test_get_invalid_member
    assert_equal nil, @issue.get_process_member('invalid_role')
  end
  
  def test_set_member
    assert @issue.set_process_member("role_name", @next_user.id)
    member = @issue.get_process_member("role_name")
    assert_equal @next_user, member.principal
  end
  
  def test_set_new_member
    assert @issue.set_process_member('virtual_role', @user.id)
    virtual_member = @issue.get_process_member('virtual_role')
    assert_equal @virtual_role, virtual_member.process_role
    assert_equal @user, virtual_member.principal
    
    assert @issue.set_process_member('virtual_role', @next_user.id)
    virtual_member = @issue.get_process_member('virtual_role')
    assert_equal @next_user, virtual_member.principal
  end
  
  def test_update_member_on_issue_save
    assert @issue.set_process_member("role_name", @next_user.id)
    assert @issue.save
    @issue.reload
    member = ProcessMember.where(:process_role_id => @role.id, :issue_id => @issue.id).first
    assert member
    assert_equal @next_user, member.principal
  end

  def test_get_process_action
    action = @issue.get_process_action(@custom_field.id.to_s)
    assert action
    assert_equal @field, action.process_field
    assert_equal "1.234", action.value
  end

  def test_get_process_action_invalid
    assert_equal nil, @issue.get_process_action("99")
  end
  
  def test_set_process_action
    assert @issue.set_process_action(@custom_field.id.to_s, "2.345", @admin)
    action = @issue.get_process_action(@custom_field.id.to_s)
    assert_equal "2.345", action.value
    assert_equal @admin, action.user
    assert action.timestamp
  end
  
  def test_set_process_action_invalid
    assert !@issue.set_process_action("99", "2.345", @admin)
  end
  
  def test_apply_action_on_issue_save
    condition = ProcessCondition.new(:comparison_mode => 'eql?', :comparison_value => "2.345", :step_if_true => @next_step, :process_field => @field)
    assert condition.save
    
    assert @issue.set_process_action(@custom_field.id.to_s, "2.345")
    assert @issue.save
    @issue.reload
    
    action = ProcessAction.where(:issue_id => @issue.id, :process_field_id => @field.id).first
    assert action
    assert_equal "2.345", action.value
    
    assert_equal @next_step, @issue.process_step
    
  end
  
  def test_apply_default_step
    @step.default_next_step  = @next_step
    @step.save
    @issue.process_step.reload
    
    assert @issue.save
    @issue.reload
    
    assert_equal @next_step, @issue.process_step
  end
  
  def test_skip_default_step_if_condition_met
    condition = ProcessCondition.new(:comparison_mode => 'eql?', :comparison_value => "2.345", :step_if_true => @next_step, :process_field => @field)
    assert condition.save
    
    default_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker, :process_role_id => @next_role.id)
    assert default_step.save
    @step.default_next_step = default_step
    @step.save
    @issue.process_step.reload

    assert @issue.set_process_action(@custom_field.id.to_s, "2.345")
    assert @issue.save
    @issue.reload
    
    action = ProcessAction.where(:issue_id => @issue.id, :process_field_id => @field.id).first
    assert action
    assert_equal "2.345", action.value
    
    assert_equal @next_step, @issue.process_step
  end
  
  def test_skip_default_step_if_next_step_set
    default_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker, :process_role_id => @next_role.id)
    assert default_step.save
    @step.default_next_step = default_step
    @step.save
    @issue.process_step.reload

    @issue.next_step = @next_step
    assert @issue.save
    @issue.reload
    
    assert_equal @next_step, @issue.process_step
    
  end
  
  def test_create_with_member
    new_issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_create',
    :description => 'IssueTest#test_create', :estimated_hours => '1:30')
    
    new_issue.set_process_member(@role.name, @user.id)
    assert new_issue.save
    
    assert_equal @user, new_issue.assigned_to
  end
  
  def test_process_step
    assert_equal @step, @issue.process_step
    @issue.process_step = @next_step
    assert_equal @next_step, @issue.process_step
    
    assert @issue.save
    @issue.reload
    assert_equal @next_step, @issue.process_step
    
    state = ProcessState.where(:issue_id => @issue.id).first
    assert state
    assert_equal @next_step, state.process_step
  end
  
end