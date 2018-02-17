Rails.application.routes.draw do

  get '/meals' => 'meals#index'
  get '/meals/new' => 'meals#new'
  get '/meals/:id' => 'meals#show', as: :meal
  get '/meals/:id/edit' => 'meals#edit', as: :edit_meal
  patch '/meals/:id' => 'meals#update'

  get '/portions/:id' => 'portions#show', as: :portion
  get '/portions/:id/edit' => 'portions#edit', as: :edit_portion
  patch '/portions/:id' => 'portions#update'

  get '/stocks/:id' => 'stocks#show', as: :stock
  get '/stocks/:id/edit' => 'stocks#edit', as: :edit_stock
  patch '/stocks/:id' => 'stocks#update'

  get '/cupboards' => 'cupboards#index'
  get '/cupboards/:id' => 'cupboards#show', as: :cupboard
  get '/cupboards/:id/edit' => 'cupboards#edit', as: :edit_cupboard
  patch '/cupboards/:id' => 'cupboards#update'

  get '/ingredients' => 'ingredients#index'
  get '/ingredients/new' => 'ingredients#new'
  get '/ingredients/:id' => 'ingredients#show', as: :ingredient
  get '/ingredients/:id/edit' => 'ingredients#edit', as: :edit_ingredient
  patch '/ingredients/:id' => 'ingredients#update'
  post 'ingredients' => 'ingredients#create'

  get  '/signup',  to: 'users#new', as: :users_new
  post '/signup',  to: 'users#create'

  resources :users
end
