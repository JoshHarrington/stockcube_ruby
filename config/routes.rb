Rails.application.routes.draw do
  root 'static_pages#home'
  # get '/about' => 'static_pages#about'

  # get '/elements' => 'static_pages#elements'

  get '/shopping_lists' => 'shopping_lists#index'
  get '/shopping_lists/new' => 'shopping_lists#new'
  get '/shopping_lists/current' => 'shopping_lists#show_current', as: :current_shopping_list
  get '/shopping_lists/current/ingredients' => 'shopping_lists#show_ingredients_current', as: :current_shopping_list_ingredients
  get '/shopping_lists/current/shop' => 'shopping_lists#shop'
  get '/shopping_lists/:id' => 'shopping_lists#show', as: :shopping_list
  get '/shopping_lists/:id/ingredients' => 'shopping_lists#show_ingredients', as: :shopping_list_ingredients
  get '/shopping_lists/:id/edit' => 'shopping_lists#edit', as: :edit_shopping_list
  patch '/shopping_lists/:id' => 'shopping_lists#update'
  post '/shopping_lists' => 'shopping_lists#create'
  post '/shopping_lists/autosave' => 'shopping_lists#autosave'
  delete '/shopping_lists/:id/delete' => 'shopping_lists#delete', as: :delete_shopping_list


  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  get '/recipes/new' => 'recipes#new'
  get '/recipes/favourites' => 'recipes#favourites', as: :favourite_recipes
  post '/recipes' => 'recipes#create'

  get '/portions/new' => 'portions#new'
  get '/portions/:id' => 'portions#show', as: :portion
  get '/portions/:id/edit' => 'portions#edit', as: :edit_portion
  patch '/portions/:id' => 'portions#update'
  post '/portions' => 'portions#create'

  get '/stocks' => 'stocks#index'
  get '/stocks/new' => 'stocks#new'
  get '/stocks/:id' => 'stocks#show', as: :stock
  get '/stocks/:id/edit' => 'stocks#edit', as: :edit_stock
  patch '/stocks/:id' => 'stocks#update'
  post '/stocks' => 'stocks#create'

  get '/cupboards' => 'cupboards#index'
  get '/cupboards/new' => 'cupboards#new'
  get '/cupboards/edit_all' => 'cupboards#edit_all', as: :edit_all_cupboard
  get '/cupboards/:id' => 'cupboards#show', as: :cupboard
  get '/cupboards/:id/edit' => 'cupboards#edit', as: :edit_cupboard
  patch '/cupboards/:id' => 'cupboards#update'
  post '/cupboards' => 'cupboards#create'
  post '/cupboards/autosave' => 'cupboards#autosave'
  post '/cupboards/autosave_sorting' => 'cupboards#autosave_sorting'

  get '/ingredients' => 'ingredients#index'
  get '/ingredients/new' => 'ingredients#new'
  get '/ingredients/:id' => 'ingredients#show', as: :ingredient
  get '/ingredients/:id/edit' => 'ingredients#edit', as: :edit_ingredient
  patch '/ingredients/:id' => 'ingredients#update'
  post '/ingredients' => 'ingredients#create'

  get  '/signup',  to: 'users#new', as: :users_new
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  delete '/demo_logout',   to: 'sessions#demo_logout'

  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :recipes do
    put :favourite, on: :member
    put :add_to_shopping_list, on: :member
  end
end
