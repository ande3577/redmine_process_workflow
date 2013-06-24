class ProcessConditionsController < ApplicationController
  unloadable
  
  before_filter :require_admin
  before_filter :find_field, :except => [ :edit, :update, :destroy ]
  before_filter :find_condition, :only => [ :edit, :update, :destroy ]


  def new
    @condition = ProcessCondition.new(:process_field => @field)
  end

  def create
    @condition = ProcessCondition.new(params[:process_condition])
    @condition.process_field = @field
    if @condition.save
      redirect_to :controller => :process_fields, :action => :edit, :id => @condition.process_field.id
      return
    end
    new
    render :action => :new
  end

  def edit
  end

  def update
    @condition.safe_attributes = params[:process_condition]
    if @condition.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => :process_fields, :action => :edit, :id => @condition.process_field.id
      return
    end
    @condition.reload
    edit
    render :action => :edit
  end

  def destroy
    field = @condition.process_field
    @condition.destroy
    redirect_to :controller => :process_fields, :action => :edit, :id => field.id
  end
  
  private
  def find_field
    id = params[:process_field_id]
    if id.nil?
      render_404
      return false
    end
        
    @field = ProcessField.where(:id => id).first
    if @field.nil?
      render_404
      return false
    end
  end
  
  def find_condition
    id = params[:id]
    if id.nil?
      render_404
      return false
    end
        
    @condition = ProcessCondition.where(:id => id).first
    if @condition.nil?
      render_404
      return false
    end
  end
  
end
