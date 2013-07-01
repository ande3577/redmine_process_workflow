class ProcessStepValidator < ActiveModel::Validator
  def validate(record)
    if record.process_step.nil? or ProcessStep.where(:id => record.process_step.id).empty?
      record.errors[:base] << "Process Step cannot be empty."
    end
  end
end

class ProcessCustomField < CustomField
  def type_name
      :label_process_plural
  end

  def process_step=(val)
    write_attribute :process_step, val if process_step.nil?
  end
  
  def process_step
    return self[:process_step] unless self[:process_step].nil?
    return process_field.process_step unless process_field.nil?
    nil
  end  
  
  def process_field
    ProcessField.where(:custom_field_id => self.id).first
  end
  
  validates_with ProcessStepValidator
  
  after_create do
    # create the process field, destroy self if cannot create it  
    self.destroy unless ProcessField.create(:process_step => process_step, :custom_field => self)
  end
  
end

