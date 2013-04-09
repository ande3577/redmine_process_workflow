# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'process_workflows', :to  => 'process#index'
get 'process_workflows/new', :to => 'process#new'
post 'process_workflows/create', :to => 'process#create'
get 'process_workflows/:id', :to => 'process#edit'
