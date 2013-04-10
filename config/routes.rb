# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'process_workflows', :to  => 'process#index'
get 'process_workflows/new', :to => 'process#new'
post 'process_workflows/create', :to => 'process#create'
get 'process_workflows/:id/steps', :to => 'process_steps#index'
get 'process_workflows/:id/steps/new', :to => 'process_steps#new'
post 'process_workflows/:id/steps/create', :to => 'process_steps#create'

get 'process_steps/:id/process_fields', :to => 'process_fields#index'
get 'process_steps/:id/process_fields/new', :to => 'process_fields#new'
post 'process_steps/:id/process_fields/create', :to => 'process_fields#create'
get 'process_fields/:id', :to => 'process_fields#edit'
post 'process_fields/:id', :to => 'process_fields#update'
delete 'process_fields/:id', :to => 'process_fields#destroy'

get 'process_steps/:id', :to => 'process_steps#edit'
post 'process_steps/:id', :to => 'process_steps#update'
delete 'process_steps/:id', :to => 'process_steps#destroy'

get 'process_workflows/:id/roles', :to => 'process_roles#index'
get 'process_workflows/:id/roles/new', :to => 'process_roles#new'
post 'process_workflows/:id/roles/create', :to => 'process_roles#create'
get 'process_roles/:id', :to => 'process_roles#edit'
post 'process_roles/:id', :to => 'process_roles#update'
delete 'process_roles/:id', :to => 'process_roles#destroy'

get 'process_workflows/:id', :to => 'process#edit'