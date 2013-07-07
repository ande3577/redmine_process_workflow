require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :projects
  fixtures :issue_statuses
  fixtures :users
  fixtures :projects_trackers
  fixtures :groups_users
  
  def setup
    @project = Project.first
    
    @tracker = Tracker.first
    @tracker.process_workflow = true
    @tracker.save
    @tracker.reload
  
    @status = IssueStatus.find(2)
    
    @role = ProcessRole.new(:name => 'role', :tracker => @tracker)
    assert @role.save 
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step', :process_role => @role)
    assert @step.save
    
    @new_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'new_step')
    assert @new_step.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float', :process_step => @step)
    assert @custom_field.save
    
    @field = @custom_field.process_field
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
      
    @issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_create',
    :description => 'IssueTest#test_create', :estimated_hours => '1:30')
    
    @issue.set_process_member(@role.name, @admin)
    
    assert @issue.save
    @issue.reload
    
    @member = @issue.get_process_member(@role.name)
    assert @member
    
    @group = Group.first
    
  end

#     Example of process workflow related parameters
#     "role"=>{"Role 1"=>"3", "Role 2"=>"1"}, "process_step"=>"2", "process_fields"=>{"custom_field_values"=>{"5"=>"Value 3"}}
    
  def test_new
    get :new, :project_id => @project.id,
      :role => { @role.name => @admin.id },
      :process_step => @new_step.id, 
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "1.2345" } }
  
    member = assigns[:issue].get_process_member(@role.name)
    assert_equal @role, member.process_role
    assert_equal @admin, member.principal
    
    action = assigns[:issue].get_process_action(@custom_field.id.to_s)
    assert action
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
    assert_equal @new_step, assigns[:issue].next_step
          
    assert_response :success
  end
  
  def test_create
    assert_difference ['Issue.count', 'ProcessAction.count', 'ProcessMember.count'] do
      post :create, :project_id => @project.id, :issue => { :subject => 'New issue', :tracker_id => @tracker.id }, 
        :role => { @role.name => @admin.id },
        :process_fields => { :custom_field_values => { @custom_field.id.to_s => "1.2345" } }
    end
    issue = Issue.last
    assert_redirected_to "/issues/#{issue.id}"
    
    assert assigns[:issue].process_field_actions
    
    member = ProcessMember.last
    assert_equal issue, member.issue
    assert_equal @admin, member.principal
    
    action = ProcessAction.last
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
    
    member = assigns[:issue].get_process_member(@role.name)
    assert_equal @role, member.process_role
    assert_equal @admin, member.principal
    
    action = assigns[:issue].get_process_action(@custom_field.id.to_s)
    assert action
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
    assert_equal @admin, issue.assigned_to
    assert_equal @status, issue.status
    
  end
  
  def test_create_with_group
    assert_difference ['Issue.count', 'ProcessMember.count'] do
      post :create, :project_id => @project.id, :issue => { :subject => 'New issue', :tracker_id => @tracker.id }, 
        :role => { @role.name => @group.id }
    end
    issue = Issue.last
    assert_redirected_to "/issues/#{issue.id}"
    
    assert assigns[:issue].process_field_actions
    
    member = ProcessMember.last
    assert_equal issue, member.issue
    assert_equal @group, member.principal
    
    
    member = assigns[:issue].get_process_member(@role.name)
    assert_equal @role, member.process_role
    assert_equal @group, member.principal
    
    assert_equal @group, issue.assigned_to
    
  end

  
  def test_create_without_required
    @custom_field.is_required  = true
    assert @custom_field.save
    
    assert_difference ['Issue.count', 'ProcessAction.count', 'ProcessMember.count'], 0 do
      post :create, :project_id => @project.id, :issue => { :subject => 'New issue', :tracker_id => @tracker.id }, 
        :role => { @role.name => @admin.id },
        :process_fields => { :custom_field_values => { @custom_field.id.to_s => "" } }
    end
    
    assert_response 200
  end
  
  def test_create_with_required
    @custom_field.is_required  = true
    assert @custom_field.save
    
    assert_difference ['Issue.count', 'ProcessAction.count', 'ProcessMember.count'] do
      post :create, :project_id => @project.id, :issue => { :subject => 'New issue', :tracker_id => @tracker.id }, 
        :role => { @role.name => @admin.id },
        :process_fields => { :custom_field_values => { @custom_field.id.to_s => "1.2345" } }
    end
    assert_redirected_to "/issues/#{Issue.last.id}"
  end
  
  def test_update
    new_user = User.find(2)
    post :update, :id => @issue.id, :issue => { :subject => 'Change subject', :tracker_id => @tracker.id }, 
      :role => { @role.name => new_user.id },
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "2.345" } }
        
    assert_redirected_to "/issues/#{@issue.id}"
    
    assert_equal 'Change subject', assigns[:issue].subject
   
    assert_equal new_user, assigns[:issue].get_process_member(@role.name).principal
    
    action = assigns[:issue].get_process_action(@custom_field.id.to_s)
    assert action
    assert_equal "2.345", action.value
      
    assert_equal @step, assigns[:issue].process_step
    
  end
  
  def test_update_invalid
    new_user = User.find(2)
    post :update, :id => @issue.id, :issue => { :subject => '', :tracker_id => @tracker.id }, 
      :role => { @role.name => new_user.id },
      :process_step => @new_step.id,
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "2.345" } }
        
    assert_response 200
    
    assert_equal '', assigns[:issue].subject
    assert_equal new_user, assigns[:issue].get_process_member(@role.name).principal
    assert_equal "2.345", assigns[:issue].get_process_action(@custom_field.id.to_s).value
   
    assert_equal @new_step, assigns[:issue].next_step
  end
  
  def test_show
    get :show, :id => @issue.id
    
    assert_response 200
    
  
    assert_equal @issue, assigns[:issue]
  end
  
end
