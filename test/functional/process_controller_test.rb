require File.expand_path('../../test_helper', __FILE__)

class ProcessControllerTest < ActionController::TestCase
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
    
    @user = User.find(2)
    @admin = User.where(:admin => true).first
  end
  
  def test_index_as_anon
    get :index
    assert_response 302
    assert_redirected_to :controller => :account, :action => :login, :back_url => "http://test.host/process_workflows"
  end
  
  def test_index_as_non_admin
    @request.session[:user_id] = @user.id
    get :index
    assert_response 403
  end
  
  def test_index_as_admin
    @request.session[:user_id] = @admin.id
    get :index
    assert_response 200 
    
    assert_equal 1, assigns(:trackers).size
    assert_equal @tracker, assigns(:trackers).first
  end
  
  def test_new_as_admin
    @request.session[:user_id] = @admin.id
    get :new
    assert_response 200
    
    assert assigns(:tracker)
  end
  
  def test_edit_invalid_id
    @request.session[:user_id] = @admin.id
    get :edit, :id => 99
    assert_response 404
  end
  
  def test_edit_non_process
    @request.session[:user_id] = @admin.id
    get :edit, :id => Tracker.find(2).id
    assert_response 404
  end
  
  def test_edit_valid_id
    @request.session[:user_id] = @admin.id
    get :edit, :id => @tracker.id
    assert_response 200
    assert_equal @tracker, assigns(:tracker)
    assert_equal 1, assigns(:steps).size
    assert_equal @step, assigns(:steps).first
  end
  
  def test_create_without_name
    @request.session[:user_id] = @admin.id

    trackers = Tracker.count
    post :create
    assert_response 200
    assert_template :new
    assert_equal trackers, Tracker.count
  end
  
  def test_create
    @request.session[:user_id] = @admin.id
    assert_difference 'Tracker.count' do
      post :create, :tracker => { :name => 'New tracker', :project_ids => ['1', '', ''], :custom_field_ids => ['1', '6', ''] }
    end
    tracker = Tracker.first(:order => 'id DESC')
    assert_redirected_to :action => 'edit', :id => tracker.id
    assert tracker.process_workflow?
    assert_equal 'New tracker', tracker.name
    assert_equal [1], tracker.project_ids.sort
    assert_equal [1, 6], tracker.custom_field_ids.sort
    assert_equal 0, tracker.workflow_rules.count
  end
  
end
