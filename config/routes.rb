Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }
  match '/404', :to => 'errors#not_found', :via => :all, as: :errors_not_found
  match '/500', :to => 'errors#internal_server_error', :via => :all, as: :errors_internal_server_error
  root 'static_pages#home'
  # get '/about' => 'static_pages#about'

  get '/logo', to: 'static_pages#logo'
  get '/cookie-policy', to: 'static_pages#cookie_policy'
  get '/privacy-policy', to: 'static_pages#privacy_policy'
  get '/terms-of-use', to: 'static_pages#terms_of_use'

  get 'password_resets/new'
  get 'password_resets/edit'

  get 'sessions/new'

  get '/portions/new' => 'portions#new'
  get '/portions/:id' => 'portions#show', as: :portion
  post '/portions' => 'portions#create'
  post '/portions/new_recipe_portion', to: 'portions#create_from_post'

  get '/stock/new' => 'stocks#new_no_id', as: :stocks_new_no_id
  get '/stock/new/:cupboard_id/custom' => 'stocks#custom_new', as: :stocks_custom_new
  get '/stock/new/:cupboard_id' => 'stocks#new', as: :stocks_new
  get '/stock/picks' => 'stocks#picks'
  get '/stock/:id' => 'stocks#show', as: :stock
  get '/stock/:id/edit' => 'stocks#edit', as: :edit_stock
  get '/stock/delete/:id' => 'stocks#delete_stock', as: :delete_stock
  patch '/stock/:id' => 'stocks#update'
  post '/stock' => 'stocks#create'
  post '/stock/delete' => 'stocks#delete_stock_post'
  post '/stock/custom' => 'stocks#create_custom', as: :create_custom_stock
  post '/stock/toggle_portion' => 'stocks#toggle_shopping_list_portion'
  post '/stock/add_shopping_list' => 'stocks#add_shopping_list'
  post '/stock/new/:cupboard_id' => 'stocks#create', as: :create_stock
  post '/stock/new' => 'stocks#create_with_params', as: :create_stock_with_params
  get '/stock' => 'stocks#index'
  post '/stocks/new_cupboard_stock', to: 'stocks#create_from_post'
  post '/stocks/edit_cupboard_stock', to: 'stocks#update_from_post'

  get '/cupboards' => 'cupboards#index'
  get '/cupboards/demo' => 'cupboards#demo'
  get '/cupboards/new' => 'cupboards#new'
  get '/cupboards/share/:id' => 'cupboards#share', as: :cupboard_share
  get '/cupboards/accept_cupboard_invite' => 'cupboards#accept_cupboard_invite'
  get '/cupboards/:id' => 'cupboards#show'
  post '/cupboards/accept_cupboard_invite' => 'cupboards#accept_cupboard_invite', as: :accept_cupboard_invite
  get '/cupboards/:id/edit' => 'cupboards#edit', as: :edit_cupboard
  patch '/cupboards/:id/edit' => 'cupboards#update'
  post '/cupboards' => 'cupboards#create'
  post '/cupboards/name_update' => 'cupboards#location_update'
  put '/cupboards/:id/delete' => 'cupboards#delete'
  post '/cupboards/autosave_sorting' => 'cupboards#autosave_sorting'
  post '/cupboards/share/:id' => 'cupboards#share_request'
  post '/cupboards/delete_quick_add_stock' => 'cupboards#delete_quick_add_stock'
  post '/cupboards/delete_cupboard_stock' => 'cupboards#delete_cupboard_stock'
  post '/cupboards/delete_cupboard_user' => 'cupboards#delete_cupboard_user'
  post '/cupboards/planner_recipes' => 'cupboards#get_latest_planner_recipes'

  get '/ingredients' => 'ingredients#index'
  get '/ingredients/new' => 'ingredients#new'
  get '/ingredients/:id' => 'ingredients#show', as: :ingredient
  get '/ingredients/:id/edit' => 'ingredients#edit', as: :edit_ingredient
  patch '/ingredients/:id' => 'ingredients#update'
  post '/ingredients' => 'ingredients#create'
  post '/ingredients/default_size_update' => 'ingredient#default_size_update', as: :default_ingredient_size_update

  delete '/demo_logout',   to: 'sessions#demo_logout'

  get '/quick_add_stock/new', to: 'user_fav_stocks#new'
  get '/quick_add_stock/:id/edit', to: 'user_fav_stocks#edit', as: :quick_add_stock_edit

  get '/profile', to: 'users#profile', as: :user_profile
  post '/users/notifications', to: 'users#notifications'
  get '/users', to: 'users#index', as: :user_list

  devise_scope :user do get "/users/sign_out" => "devise/sessions#destroy" end

  # get '/google_login', to: redirect('/auth/google_oauth2')
  # get '/auth/google_oauth2/callback', to: 'users#google_auth'

  post '/feedback/submit' => 'feedback#submit'

  get '/planner', to: 'planner#index', as: :planner
  post '/planner', to: 'planner#refresh', as: :planner_refresh
  get '/planner/shopping_list', to: 'planner#get_shopping_list_content'
  post '/planner/shopping_list', to: 'planner#get_shopping_list_content'
  get '/list/:gen_id', to: 'planner#list', as: :shopping_list_share
  post '/planner/recipe_add', to: 'planner#recipe_add_to_planner'
  post '/planner/recipe_update', to: 'planner#recipe_update_in_planner'
  post '/planner/update_portion', to: 'planner#update_portion'
  post '/planner/recipe_delete', to: 'planner#delete_recipe_from_planner'

  resources :user_fav_stocks
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  post '/recipes/portion_delete', to: 'recipes#portion_delete'
  post '/recipes/add_image', to: 'recipes#add_image'
  get '/recipes/favourites', to: 'recipes#favourites', as: :favourite_recipes
  get '/recipes/yours', to: 'recipes#yours', as: :your_recipes
  post '/recipes/update_matches', to: 'recipes#update_recipe_matches'

  resources :recipes do
    member do
      # get 'add_to_shopping_list'
      get 'favourite'
      get 'publish_update', as: 'publish_update'
      get 'delete', as: 'delete'
    end
  end
end
