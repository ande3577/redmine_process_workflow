class ProcessRole < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'name'
  
  belongs_to :tracker
  has_many :process_members, :dependent => :destroy
  
  validates_presence_of :tracker
  validates :name, :length => { :minimum => 1 }
  
    
end
