module ProcessStepsHelper
  def role_name(step)
    if step.role_is_author?
      return author_role_string()
    elsif step.process_role.nil?
      return ""
    else
      return step.process_role.name      
    end
  end
  
  def author_role_string()
    return "<< #{l(:field_author)} >>"
  end
end
