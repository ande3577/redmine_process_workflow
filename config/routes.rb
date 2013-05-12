# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources 'process_workflows', :only => [ :index, :new, :create, :edit ]

resources 'trackers', :only => [] do
  resources 'process_steps', :only => [:index, :new, :create]
  resources 'process_roles', :only => [:index, :new, :create]
end
  
resources 'process_steps', :only => [:edit, :update, :destroy] do
  resources 'process_fields', :only => [:index, :new, :create]
end

resources 'process_fields', :only => [:edit, :update, :destroy]
  
resources 'process_roles', :only => [:edit, :update, :destroy]
 