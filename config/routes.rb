Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/metric/:key', to: 'metrics#create'
  get '/metrics', to: 'metrics#aggregate'
  get '/metrics/all', to: 'metrics#show_all'
  get '/metric/name/:name', to: 'metrics#show_by_name'
  get '/metric/key/:key', to: 'metrics#show_by_key'
  delete '/metric/:key', to: 'metrics#destroy'

  get '/test', to: 'application#lifecheck'
end
