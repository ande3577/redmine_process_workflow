class ProcessCustomField < CustomField
#  belongs_to :process_field
  
  def type_name
      :label_process_plural
  end
  
  def process_field
    ProcessField.where(:custom_field_id => self.id).first
  end
end