Rails.application.routes.draw do
  
  post 'credentials/set_credentials'

  get 'metrics/:number', to: "metrics#get_cluster_metrics"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
