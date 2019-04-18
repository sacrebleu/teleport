Rails.application.routes.draw do
  get 'health/get_cluster_health'
  # resources :credentials
  get 'metrics/:number', to: "metrics#get_cluster_metrics"
  get 'metrics/:number/core', to: "metrics#get_core_stats"
  get 'metrics/:number/db', to: "metrics#get_db_stats"
  get 'metrics/:number/pretty', to: "metrics#index"

  get 'health/:number', to: 'health#get_cluster_health'
  get 'health/:number/sanity', to: 'health#sanity_check'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
