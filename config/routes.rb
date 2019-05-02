# frozen_string_literal: true

Rails.application.routes.draw do
  # resources :credentials
  get 'metrics/:number', to: 'metrics#fetch'
  get 'metrics/:number/display', to: 'metrics#display'

  # get 'health/get_cluster_health'
  get 'health/',               to: 'health#index'
  get 'health/:number',        to: 'health#cluster_health'
  get 'health/:number/sanity', to: 'health#cluster_status'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
