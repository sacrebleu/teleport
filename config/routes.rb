Rails.application.routes.draw do


  root to: 'cluster#index'

  # resources :credentials


  post 'credentials/set_credentials'
  get 'credentials/populate'

  get 'cluster', to: 'cluster#index'
  get 'cluster/new', to: 'cluster#new'

  post 'cluster/create', to: 'cluster#create'

  get 'metrics/:number', to: "metrics#get_cluster_metrics"
  get 'metrics/:number/pretty', to: "metrics#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
