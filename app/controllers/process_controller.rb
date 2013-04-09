class ProcessController < ApplicationController
  unloadable
  
  before_filter :require_admin
  before_filter :find_tracker, :except => [ :index, :new, :create ]

  def index
    @trackers = []
      
    Tracker.sorted.each do |t|
      if t.process_workflow?
        @trackers << t
      end
    end
    
    respond_to do |format|
      format.html
    end
  end

  def new
    @tracker = Tracker.new
  end
  
  def edit
    @steps = ProcessStep.where(:tracker_id => @tracker.id)
    
    respond_to do |format|
      format.html
    end
  end

  def create
    @tracker = Tracker.new(params[:tracker])
    @tracker.process_workflow = true
    if @tracker.save
      redirect_to :action => :edit, :id => @tracker.id
      return  
    end
    new
    respond_to do |format|
      format.html { render :action => :new }
    end
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
  
end
