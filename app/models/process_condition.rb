class ProcessCondition < ActiveRecord::Base
  unloadable
  
  belongs_to :process_field
  belongs_to :process_step
  
  validates_presence_of :process_step, :process_field
  validates :comparison_mode, :inclusion => { :in => %w(eql? lt? gt? ne?) }
  
  def evaluate(value)
    case comparison_mode
    when 'eql?'
      return value.eql?(field_value)
    when 'lt?'
      return value < field_value
    when 'gt?'
      return value > field_value
    when 'ne?'
      return value.ne?(field_value)
    end
  end
end
