require File.expand_path('../../test_helper', __FILE__)

class IssuesControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :projects
  fixtures :issue_statuses
  fixtures :users
  fixtures :projects_trackers
  
  def setup
    @project = Project.first
    
    @tracker = @project.trackers.first
    @tracker.process_workflow = true
    @tracker.save
    @tracker.reload
  
    @status = IssueStatus.first
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    
    @new_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'new_step')
    assert @new_step.save
    
    @role = ProcessRole.new(:name => 'role', :tracker => @tracker)
    assert @role.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float', :process_step => @step)
    assert @custom_field.save
    
    @field = @custom_field.process_field
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
      
    @issue = Issue.new(:project_id => 1, :tracker => @tracker, :author_id => 3,
    :status_id => 1, :priority => IssuePriority.all.first,
    :subject => 'test_create',
    :description => 'IssueTest#test_create', :estimated_hours => '1:30')
    
    assert @issue.save
    
    @member = ProcessMember.new(:issue => @issue, :process_role => @role, :principal => @admin)
    assert @member.save
    
    @action = @issue.process_actions.first
    assert @action
    
  end

#     Example of process workflow related parameters
#     "role"=>{"Role 1"=>"3", "Role 2"=>"1"}, "process_step"=>"2", "process_fields"=>{"custom_field_values"=>{"5"=>"Value 3"}}
    
  def test_new
    get :new, :project_id => @project.id,
      :role => { @role.name => @admin.id },
      :process_step => @new_step.id, 
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "1.2345" } }
  
    members = assigns[:process_members]
    assert !members.nil?
    assert members.any?
    
    member = assigns[:process_members][@role.name]
    assert_equal @role, member.process_role
    assert_equal @admin, member.principal
    
    actions = assigns[:process_actions]
    assert !actions.nil?
    assert actions.any?
    
    action = actions[@custom_field.id.to_s]
    assert action
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
    assert_equal @new_step, assigns[:process_step]
          
    assert_response :success
  end
  
  def test_new_with_default_field_value
    @custom_field.update_attribute(:default_value, "1.2345")
    assert @custom_field.save
    
    get :new, :project_id => @project.id,
      :role => { @role.name => @admin.id },
      :process_step => @new_step.id
     
    action = assigns[:process_actions][@custom_field.id.to_s]
    assert action
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
  end
  
  def test_create
    assert_difference ['Issue.count', 'ProcessAction.count', 'ProcessMember.count'] do
      post :create, :project_id => @project.id, :issue => { :subject => 'New issue', :tracker_id => @tracker.id }, 
        :role => { @role.name => @admin.id },
        :process_fields => { :custom_field_values => { @custom_field.id.to_s => "1.2345" } }
    end
    issue = Issue.last
    assert_redirected_to "/issues/#{issue.id}"
    
    member = ProcessMember.last
    assert_equal issue, member.issue
    assert_equal @admin, member.principal
    
    action = ProcessAction.last
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
    
    members = assigns[:process_members]
    assert !members.nil?
    assert members.any?
    
    member = assigns[:process_members][@role.name]
    assert_equal @role, member.process_role
    assert_equal @admin, member.principal
    
    actions = assigns[:process_actions]
    assert !actions.nil?
    assert actions.any?
    
    action = actions[@custom_field.id.to_s]
    assert action
    assert_equal @custom_field, action.process_field.custom_field
    assert_equal "1.2345", action.value
    
  end
  
  def test_update
    new_user = User.find(2)
    post :update, :id => @issue.id, :issue => { :subject => 'Change subject', :tracker_id => @tracker.id }, 
      :role => { @role.name => new_user.id },
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "2.345" } }
        
    assert_redirected_to "/issues/#{@issue.id}"
    
    @issue.reload
    @member.reload
    @action.reload
    
    assert_equal 'Change subject', @issue.subject
    assert_equal new_user, @member.principal
    assert_equal "2.345", @action.value
   
    members = assigns[:process_members]
    assert !members.nil?
    assert members.any?
    
    assert_equal @member, members[@role.name]
    
    actions = assigns[:process_actions]
    assert !actions.nil?
    assert actions.any?
    assert_equal @action, assigns[:process_actions][@custom_field.id.to_s]
      
    assert_equal @step, assigns[:process_step]
    
  end
  
  def test_update_invalid
    new_user = User.find(2)
    post :update, :id => @issue.id, :issue => { :subject => '', :tracker_id => @tracker.id }, 
      :role => { @role.name => new_user.id },
      :process_step => @new_step.id,
      :process_fields => { :custom_field_values => { @custom_field.id.to_s => "2.345" } }
        
    assert_response 200
    
    assert_equal '', assigns[:issue].subject
    assert_equal new_user, assigns[:process_members][@role.name].principal
    assert_equal "2.345", assigns[:process_actions][@custom_field.id.to_s].value
   
    assert_equal @new_step, assigns[:process_step]
  end
  
  def test_show
    get :show, :id => @issue.id
    
    assert_response 200
    
    members = assigns[:process_members]
    assert !members.nil?
    assert members.any?
   
    assert_equal @member, members[@role.name]
   
    actions = assigns[:process_actions]
    assert !actions.nil?
    assert actions.any?
    assert_equal @action, assigns[:process_actions][@custom_field.id.to_s]
       
    assert_equal @step, assigns[:process_step]
  end
  
end
