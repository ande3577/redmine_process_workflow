module ProcessWorkflowIssuePatch
  def self.included(base)
    unloadable
    
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.class_eval do
      has_one :process_state, :dependent => :destroy
      has_many :process_actions, :dependent => :destroy
      has_many :process_members, :dependent => :destroy
      after_create :init_process
      validate :validate_process_fields
      validate :validate_process_roles
      before_save :apply_next_step
      before_save :apply_process_actions
      alias_method_chain :safe_attribute?, :process
      before_save {|issue| issue.send :after_tracker_change if !issue.id_changed? && issue.tracker_id_changed?}
      after_save :save_process_members
      after_save :save_process_state
      after_save :save_process_actions
      after_initialize :initialize_process_field_actions
      attr_accessor 'process_field_actions'
      after_initialize :initialize_process_members
      attr_accessor 'process_member_list'
      attr_accessor 'next_step'
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def apply_process_step_change(step)
      return true if step.nil?
      
      self.status = step.issue_status
      
      self.process_step = step
      
      if step.role_is_author?
        next_assignee = self.author
      else
        next_member = get_process_member(step.process_role.name) unless step.process_role.nil?
        next_assignee = next_member.principal unless next_member.nil?
      end
      self.assigned_to = next_assignee unless next_assignee.nil?
      true
    end
    
    def process_step
      return nil unless tracker.process_workflow?
      step = read_attribute(:process_step)
      state = self.process_state if step.nil?
      step = state.process_step unless state.nil?
      step = tracker.process_steps.first if step.nil?
      step
    end
    
    def process_step=(step)
      return unless tracker.process_workflow?
      write_attribute(:process_step, step)
    end
    
    def get_process_member(role_name)
      return process_member_list[role_name] unless process_member_list[role_name].nil?
      role = ProcessRole.where(:name => role_name).first
      return nil if role.nil?
      member = ProcessMember.where(:issue_id => self.id, :process_role_id => role.id).first if !self.id.nil?
      return member unless member.nil?
      return ProcessMember.new(:issue => self, :process_role => role)
    end
    
    def set_process_member(role_name, user_id)
      member = get_process_member(role_name)
      return false if member.nil?
      member.user_id = user_id
      process_member_list[role_name] = member
      true 
    end
    
    def get_process_action(custom_field_id_string)
      return self.process_field_actions[custom_field_id_string] unless process_field_actions[custom_field_id_string].nil?
      custom_field = ProcessCustomField.where(:id => custom_field_id_string).first
      return nil if custom_field.nil?
      field = ProcessField.where(:custom_field_id => custom_field_id_string).first
      return nil if field.nil?
      action = ProcessAction.where(:issue_id => self.id, :process_field_id => field.id).first unless self.id.nil?
      return action unless action.nil?
      return ProcessAction.new(:issue => self, :process_field => field, :value => custom_field.default_value)
    end
    
    def set_process_action(custom_field_id_string, value, user = User.current, timestamp = Time.now)
      action = get_process_action(custom_field_id_string)
      return false if action.nil?
      action.value = value
      action.user = user
      action.timestamp = timestamp
      self.process_field_actions[custom_field_id_string] = action
      true
    end
    
    def safe_attribute_with_process?(attr, user=nil)
      if self.tracker.process_workflow? && ((attr == 'assigned_to_id') || (attr == 'status_id'))
        return false
      else
        return safe_attribute_without_process?(attr, user)        
      end
    end
    
    def validate_process_fields
      return unless tracker.process_workflow?
      
      for field in process_step.process_fields
        custom_field = field.custom_field
        if custom_field.is_required? and (self.process_field_actions[custom_field.id.to_s].nil? or self.process_field_actions[custom_field.id.to_s].value.nil? or self.process_field_actions[custom_field.id.to_s].value.blank?)
          errors.add :base, custom_field.name + ' ' + l('activerecord.errors.messages.blank')
        end
      end
    end
    
    def validate_process_roles
      return unless tracker.process_workflow?
      
      for role in tracker.process_roles
        if role.is_required? and (self.process_member_list[role.name].nil? or self.process_member_list[role.name].principal.nil?)
          errors.add :base, role.name + ' ' + l('activerecord.errors.messages.blank')
        end
      end
    end
    
    def initialize_process_members
      self.process_member_list ||= {}
    end
    
    def initialize_process_field_actions
      self.process_field_actions ||= {} # just in case the :attachments were passed to .new
    end
    
    def current_step
      step = read_attribute(:current_step).nil?
      step = process_step if step.nil?
      step
    end
    
  end
  
  private
  
  def apply_process_actions
    return true unless self.tracker.process_workflow?
    process_field_actions.each do |custom_field_id_string, a|
      field = a.process_field
      unless field.nil?
        existing_action = ProcessAction.where(:issue_id => self.id, :process_field_id => field.id)
        if a != existing_action or a.value != existing_action.value # only apply the change if the value actually changed
          if field.process_step == process_step
            a.apply_action(self)
          end
        end
      end
    end
  end
  
  def apply_next_step
    if self.tracker.process_workflow? and !self.next_step.nil? and self.next_step != self.process_step
      step = self.next_step
      self.next_step = nil
      apply_process_step_change(step)
    end
  end
  
  def init_process
    if self.tracker.process_workflow?
      apply_process_step_change(self.tracker.process_steps.first)
    end
  end
  
  def after_tracker_change
    if self.tracker.process_workflow?
      apply_process_step_change(self.tracker.process_steps.first)
    else
      ProcessState.destroy_all(:issue_id => self.id)
      ProcessAction.destroy_all(:issue_id => self.id)
      ProcessMember.destroy_all(:issue_id => self.id)
    end
  end
  
  def save_process_members
    return true unless self.tracker.process_workflow?
    
    self.process_member_list.each do |name, m|
      # check for a member that actually changed to prevent infinite recursion
      existing_member = ProcessMember.where(:issue_id => self.id, :process_role_id => m.process_role.id).first
      if m != existing_member or m.principal != existing_member.principal 
        m.save
      end
    end
  end
  
  def save_process_state
    state = self.process_state
    if state.nil?
      state = ProcessState.new(:issue => self, :process_step => process_step)
    else
      state.process_step = process_step 
    end
    return state.save 
  end
  
  def save_process_actions
    return true unless self.tracker.process_workflow?
    process_field_actions.each do |custom_field_id_string, a|
      a.save
    end
  end
  
  
end

Issue.send(:include, ProcessWorkflowIssuePatch)