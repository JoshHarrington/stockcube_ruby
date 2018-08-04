## todos on staging and prod

(s) rails db:migrate
(s) heroku run rake new_units:find_or_create_new_units --app=stockcubes-staging
(s) heroku run rake new_ingredients:find_or_create_new_ingredients --app=stockcubes-staging
(s) heroku run rake add_fav_stock_if_none:add_fav_stock --app=stockcubes-staging

App crashing
heroku run rails console  --app=stockcubes-staging
-----

rails db:migrate
heroku run rake new_units:find_or_create_new_units --app=desolate-woodland-40224
heroku run rake new_ingredients:find_or_create_new_ingredients --app=desolate-woodland-40224
heroku run rake add_fav_stock_if_none:add_fav_stock --app=desolate-woodland-40224
