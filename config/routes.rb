Rails.application.routes.draw do

  root to: 'bowls#index'
  namespace :api, defaults: {format: :json} do
    resources :bowlings, only: [:show, :create, :update]
  end
  match '*path', :to => 'application#routing_error', :via => :all
end
