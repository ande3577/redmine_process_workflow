class ProcessStep < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker
  belongs_to :issue_status
  has_many :process_fields
  has_many :process_condition
  has_one :process_role
  
  validates_presence_of :tracker, :issue_status
  validates :name, :length => { :minimum => 1 }
    
end
