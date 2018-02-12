Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/meals' => 'meals#index'
  get '/meals/new' => 'meals#new'
  get '/meals/:id' => 'meals#show', as: :meal
  get '/cupboards' => 'cupboard#index'
  get '/cupboards/:id' => 'cupboard#show', as: :cupboard
  get '/ingredients' => 'ingredients#index'
  get '/ingredients/new' => 'ingredients#new'
  get '/ingredients/:id' => 'ingredients#show', as: :ingredient
  post 'ingredients' => 'ingredients#create'
end
