Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/transactions/new', to: 'transactions#new'
  post '/transactions/upload', to: 'transactions#upload'
  get '/transactions/edit/:ids', to: 'transactions#bulk_edit'
end
