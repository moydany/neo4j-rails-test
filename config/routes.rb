Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get '/metrics', to: 'metrics#index'
  post '/metric/:key', to: 'metrics#create'
  get '/metrics/all', to: 'metrics#show_all'
end
