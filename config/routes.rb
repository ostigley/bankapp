Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'summary#index'
  get '/transactions/new', to: 'transactions#new'
  post '/transactions/upload', to: 'transactions#upload'
  get '/transactions/edit/:ids', to: 'transactions#bulk_edit'
  post '/transactions/edit', to: 'transactions#update'

  get '/summary/:month/:year', to: 'summary#show'
  get '/category/:category', to: 'summary#category'
end
