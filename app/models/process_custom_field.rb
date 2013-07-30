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
  
  def visible_by?(project, user=User.current)
    visible? || user.admin? || (roles & user.roles_for_project(project)).present?
  end
  
  validates_with ProcessStepValidator
  
  after_create do
    # create the process field, destroy self if cannot create it  
    self.destroy unless ProcessField.create(:process_step => process_step, :custom_field => self)
  end
  
  validate do
    #if we get an error that the name has already been taken, and it is the only name error,
    # delete it if it is unique for the step
    errors.each do |attribute, error|
      if attribute == :name and errors.get(attribute).size == 1 and error == I18n.t(:taken, scope: [:activerecord, :errors, :messages]) and name_unique_for_step?()
        errors.delete(attribute)
      end
    end
  end
  
  private
  def name_unique_for_step?()
    for f in self.process_step.process_fields
      if self.name == f.custom_field.name
        return false
      end
    end
    true
  end
  
end

