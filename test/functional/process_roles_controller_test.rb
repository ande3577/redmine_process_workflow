require File.expand_path('../../test_helper', __FILE__)

class ProcessRolesControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :users
  
  def setup
    @tracker = Tracker.first
    @tracker.process_workflow = true
    @tracker.save
    @tracker.reload
    
    @role = ProcessRole.new(:name => 'role', :tracker => @tracker)
    assert @role.save
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
  end
  
  def test_index
    get :index, :id => @tracker.id
    assert_response 200
    
    assert assigns(:roles)
    assert_equal 1, assigns(:roles).size
    assert_equal @role, assigns(:roles).first
  end
  
  def test_new
    get :new, :id => @tracker.id
    assert_response 200
    
    role = assigns(:role)
    assert role
    assert_equal @tracker, role.tracker 
  end
  
  def test_edit
    get :edit, :id => @role.id
    assert_response 200
    
    role = assigns(:role)
    assert role
    assert_equal @role, role
  end
  
  def test_create
    assert_difference 'ProcessRole.count' do
          post :create, :id => @tracker.id, :process_role => { :name => 'New role' }
    end
    assert_redirected_to :controller => :process, :action => 'edit', :id => @tracker.id
    role = ProcessRole.last
    assert_equal 'New role', role.name
    assert_equal @tracker, @role.tracker
  end
  
  def create_without_name
    assert_difference 'ProcessRole.count', 0 do
          post :create, :id => @tracker.id, :process_role => { :invalid => 'blah' }
    end
    assert_response 200
    assert_template :new
  end
  
  def test_update
    new_tracker = Tracker.find(2)
    post :update, :id => @role.id, :process_role => { :name => 'New name', :tracker_id => new_tracker.id }
    assert_redirected_to :controller => :process, :action => 'edit', :id => new_tracker.id
    @role.reload
    assert_equal 'New name', @role.name
    assert_equal new_tracker, @role.tracker
  end
  
  def test_update_with_invalid_tracker_id
    post :update, :id => @role.id, :process_role => { :name => 'New name', :tracker_id => 99 }
    assert_response 200
    assert_template :edit
  end
  
  def test_destroy
    assert_difference 'ProcessRole.count', -1 do
      delete :destroy, :id => @role.id
    end
    assert_redirected_to :controller => :process, :action => 'edit', :id => @tracker.id
  end
end
