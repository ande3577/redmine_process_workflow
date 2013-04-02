class ProcessCondition < ActiveRecord::Base
  unloadable
  
  belongs_to :process_field
  belongs_to :process_step
  
  validates_presence_of :process_step, :process_field
  validates :comparison_mode, :inclusion => { :in => %w(eql? lt? gt? ne?) }
  
end
