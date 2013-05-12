class ProcessFieldsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_step, :except => [ :edit, :update, :destroy ]
  before_filter :find_field, :only => [ :edit, :update, :destroy ]

  def index
    @fields = @step.process_fields
  end

  def new
    @field = ProcessField.new(:process_step => @step)
  end

  def edit
  end

  def create
    @field = ProcessField.new(params[:process_field])
    @field.process_step = @step
    if @field.save
      redirect_to :controller => :process_steps, :action => :edit, :id => @field.process_step.id
      return
    end
    new
    render :action => :new
  end

  def update
    @field.safe_attributes = params[:process_field]
    if @field.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => :process_steps, :action => :edit, :id => @field.process_step.id
      return
    end
    @field.reload
    edit
    render :action => :edit
  end

  def destroy
    step = @field.process_step
    @field.destroy
    redirect_to :controller => :process_steps, :action => :edit, :id => step.id
  end
  
  private
  def find_step
    id = params[:process_step_id]
    if id.nil?
      render_404
      return false
    end
        
    @step = ProcessStep.where(:id => id).first
    if @step.nil?
      render_404
      return false
    end
  end
  
  def find_field
    id = params[:id]
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
end
