class ProcessStepsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_tracker, :except => [ :edit, :update, :destroy  ]
  before_filter :find_step, :only => [ :edit, :update, :destroy ] 

  def index
    @steps = ProcessStep.where(:tracker_id => @tracker.id)
  end

  def new
    @step = ProcessStep.new
  end

  def edit
  end

  def create
    @step = ProcessStep.new(params[:process_step])
    @step.tracker = @tracker
    @step.save
    redirect_to :controller => :process, :action => :edit, :id => @tracker.id
  end

  def update
    if @step.update_attributes(params[:process_step])
      flash[:notice] = l(:notice_successful_update)
    end
    redirect_to :controller => :process, :action => :edit, :id => @step.tracker_id
  end

  def destroy
    @tracker = @step.tracker
    @step.destroy
    redirect_to :controller => :process, :action => :edit, :id => @tracker.id
  end
  
  private
  def find_tracker
    id = params[:id]
    if id.nil?
      render_404
      return false
    end

    @tracker = Tracker.where(:id => id).first
    if @tracker.nil? || !@tracker.process_workflow?
      render_404
      return false
    end
  end
  
  def find_step
    id = params[:id]
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
  
  
end
