require File.expand_path('../../test_helper', __FILE__)

class ProcessFieldsControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :users
  fixtures :custom_fields
  
  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float', :process_step => @step)
    assert @custom_field.save
    
    @field = @custom_field.process_field
    
    @condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true => @step)
    assert @condition.save
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
  end
  
  def test_index
    get :index, :process_step_id => @step.id
    assert_response 200
    
    step = assigns(:step)
    assert step
    assert_equal @step, step
    
    fields = assigns(:fields)
    assert fields
    assert_equal 1, fields.size
    assert_equal @field, fields.first
  end
  
  def test_new
    get :new, :process_step_id => @step.id, :process_custom_field => {:name => "custom field" }
    assert_response 200
    
    field = assigns(:field)
    assert field
    
    custom_field = assigns(:custom_field)
    assert custom_field
    assert_equal "custom field", custom_field.name
    
    assert_equal @step, assigns(:step)
  end
  
  def test_edit
    get :edit, :id => @field.id
    assert_response 200
    
    field = assigns(:field)
    assert field
    assert_equal @field, field
    
    custom_field = assigns(:custom_field)
    assert custom_field
    assert_equal @custom_field, custom_field
    
    conditions = assigns(:conditions)
    assert conditions
    assert_equal @condition, conditions.first
  end
  
  def test_create
    assert_difference ['ProcessField.count', 'ProcessCustomField.count'] do
          post :create, :process_step_id => @step.id, :process_custom_field => { :name => 'new_custom_field', :field_format => 'float' }
    end
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id
    
    new_field = ProcessField.last
    assert_equal @step, new_field.process_step
    
    new_custom_field = ProcessCustomField.last
    assert_equal new_custom_field, new_field.custom_field
    assert_equal 'new_custom_field', new_custom_field.name
  end
  
  def test_create_invalid
    new_custom_field = CustomField.find(2)
    assert_difference ['ProcessField.count', 'ProcessCustomField.count'], 0 do
          post :create, :process_step_id => @step.id, :process_custom_field => { :field_format => 'invalid' }
    end
    assert_response 200
    assert_template :new
  end
  
  def test_update
    post :update, :id => @field.id, :process_custom_field => { :name => 'new_name' }
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id  
    
    @custom_field.reload
    assert_equal 'new_name', @custom_field.name
  end
  
  def test_update_invalid
    post :update, :id => @field.id, :process_custom_field => { :name => '' }
    assert_response 200
    assert_template :edit
  end
  
  def test_destroy
    assert_difference 'ProcessField.count', -1 do
      delete :destroy, :id => @field.id
    end
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id
  end
end
