# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'process_workflows', :to  => 'process#index'
get 'process_workflows/new', :to => 'process#new'
post 'process_workflows/create', :to => 'process#create'
get 'process_workflows/:id', :to => 'process#edit'
get 'process_workflows/:id/steps', :to => 'process_steps#index'
get 'process_workflows/:id/steps/new', :to => 'process_steps#new'
post 'process_workflows/:id/steps/create', :to => 'process_steps#create'
get 'process_steps/:id', :to => 'process_steps#edit'
post 'process_steps/:id', :to => 'process_steps#update'
delete 'process_steps/:id', :to => 'process_steps#destroy'