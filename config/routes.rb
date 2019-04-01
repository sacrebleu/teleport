Rails.application.routes.draw do
  # resources :credentials
  get 'metrics/:number', to: "metrics#get_cluster_metrics"
  get 'metrics/:number/core', to: "metrics#get_core_stats"
  get 'metrics/:number/db', to: "metrics#get_db_stats"
  get 'metrics/:number/pretty', to: "metrics#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
