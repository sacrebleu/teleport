Rails.application.routes.draw do
  
  post 'credentials/set_credentials'

  get 'cluster', to: 'cluster#index'

  get 'metrics/:number', to: "metrics#get_cluster_metrics"
  get 'metrics/:number/pretty', to: "metrics#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
