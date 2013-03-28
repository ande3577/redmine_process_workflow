class ProcessStep < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker
  belongs_to :issue_status
  has_one :process_role
  has_many :process_fields
  has_many :process_conditions

  validates_presence_of :tracker, :issue_status
  validates :name, :length => { :minimum => 1 }
    
end
