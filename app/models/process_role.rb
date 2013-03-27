class ProcessRole < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker, :user
  has_many :process_members
  
  validate_presence_of :tracker, :user, :name
end
