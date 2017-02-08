Rails.application.routes.draw do
  resources :achievements, only: [ :new, :create ]
  root to: 'welcome#index'
end
