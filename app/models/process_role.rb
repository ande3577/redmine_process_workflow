class ProcessRole < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker
  has_many :process_members
  
  validates_presence_of :tracker
  validates :name, :length => { :minimum => 1 }
  
    
end
