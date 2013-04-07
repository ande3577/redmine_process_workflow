class ProcessStep < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker
  acts_as_list :scope => :tracker
  
  belongs_to :issue_status
  has_many :process_fields
  has_many :process_conditions

  validates_presence_of :tracker, :issue_status
  validates :name, :length => { :minimum => 1 }
    
  def process_role
    ProcessRole.where(:id => self.process_role_id).first
  end
  
  def process_role=(r)
    if r.nil?
      self.process_role_id = r
    else
      self.process_role_id = r.id      
    end
  end
    
end
