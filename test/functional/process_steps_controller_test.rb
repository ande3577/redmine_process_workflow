require File.expand_path('../../test_helper', __FILE__)

class ProcessStepsControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :users
  
  def setup
    @tracker = Tracker.first
    @tracker.process_workflow = true
    @tracker.save
    @tracker.reload
    
    @status = IssueStatus.first
    @step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert @step.save
    
    @role = ProcessRole.new(:name => 'role', :tracker => @tracker)
    assert @role.save
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
  end
  
  def test_index
    get :index, :tracker_id => @tracker.id
    assert_response 200
    assert_equal @tracker, assigns(:tracker)
    
    assert assigns(:steps)
    assert_equal 1, assigns(:steps).size
    assert_equal @step, assigns(:steps).first
  end
  
  def test_sorted
    
    new_step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert new_step.save
    
    new_step.move_to_top
    
    get :index, :tracker_id => @tracker.id
    assert_response 200
    assert_equal 2, assigns(:steps).size
    assert_equal new_step, assigns(:steps).first
  end
  
  def test_new
    get :new, :tracker_id => @tracker.id, :process_step => { :name => 'New step'}
    assert_response 200
    assert assigns(:step)
    assert_equal 'New step', assigns(:step).name
  end
  
  def test_edit
    get :edit, :id => @step.id
    assert_response 200
    assert assigns(:step)
    assert_equal @step, assigns(:step)
    
    assert assigns(:tracker)
    assert_equal @tracker, assigns(:tracker)
    
    assert assigns(:fields)
  end
  
  def test_create
    assert_difference 'ProcessStep.count' do
          post :create, :tracker_id => @tracker.id, :process_step => { :name => 'New step', :issue_status_id => @status.id, :process_role_id => @role.id }
    end
    step = ProcessStep.first(:order => 'id DESC')
    assert_redirected_to :controller => :process_steps, :action => 'edit', :id => step.id
    assert_equal 'New step', step.name
    assert_equal @status, step.issue_status
    assert_equal @tracker, step.tracker
    assert_equal @role, step.process_role
  end
  
  def test_create_without_name
    assert_difference 'ProcessStep.count', 0 do
          post :create, :tracker_id => @tracker.id, :process_step => { :issue_status_id => @status.id, :process_role_id => @role.id }
    end
    assert_response 200
    assert_template :new
  end
  
  def test_create_with_author
    assert_difference 'ProcessStep.count' do
          post :create, :tracker_id => @tracker.id, :process_step => { :name => 'New step', :issue_status_id => @status.id, :process_role_id => ProcessStep::AUTHOR }
    end
    step = ProcessStep.first(:order => 'id DESC')
    assert_redirected_to :controller => :process_steps, :action => 'edit', :id => step.id
    assert step.role_is_author?
  end
  
  def test_update
    new_status = IssueStatus.find(2)
    new_tracker = Tracker.find(2)
    new_role = ProcessRole.new(:name => 'new_role', :tracker => new_tracker)
    assert new_role.save
    
    flash[:notice] = nil
    post :update, :id => @step.id, :process_step => { :name => 'Updated name', :issue_status_id => new_status.id, :tracker_id => new_tracker.id, :process_role_id => new_role.id }
    assert_redirected_to :controller => :process_steps, :action => 'edit', :id => @step.id
    @step.reload
    assert_equal 'Updated name', @step.name
    assert_equal new_status, @step.issue_status
    assert_equal @tracker, @step.tracker
    assert_equal new_role, @step.process_role
    assert flash[:notice]
  end
  
  def test_update_with_author
     post :update, :id => @step.id, :process_step => { :process_role_id => ProcessStep::AUTHOR }
     assert_redirected_to :controller => :process_steps, :action => 'edit', :id => @step.id
     @step.reload
     assert @step.role_is_author?
   end
  
  def test_update_with_invalid_status_id
    new_status = IssueStatus.find(2)
    new_tracker = Tracker.find(2)
    new_role = ProcessRole.new(:name => 'new_role', :tracker => new_tracker)
    assert new_role.save
    
    flash[:notice] = nil
    post :update, :id => @step.id, :process_step => { :name => 'Updated name', :issue_status_id => 99, :tracker_id => new_tracker.id, :process_role_id => new_role.id }
    assert_response 200
    assert_template :edit  
  end
  
  def test_destroy
    assert_difference 'ProcessStep.count', -1 do
      delete :destroy, :id => @step.id
    end
    assert_redirected_to :controller => :process_workflows, :action => 'edit', :id => @tracker.id
  end
end
