# README

Welcome to this rudamentary prototype for the StockCube App

* Ruby version - 2.5.0  

I recommend using [Rbenv](https://github.com/rbenv/rbenv) to manage your Ruby environments and using [Homebrew](https://brew.sh/) to manage your packages (if you're on a Mac).

## Steps to run
1. Pull down repo
2. Run `bundle install` to install Gems
3. Run `rake db:migrate` to setup the database
4. Run `rake db:seed` to populate the database from the db/seeds.rb file
5. Run `rails server` to run server
6. See app at [http://localhost:3000](http://localhost:3000)

## To dos
- ~~Set up default units for all ingredients~~
	- ~~Add some example amounts and units for stock and portions in `seeds.rb`~~
- ~~Could move unit over to ingredient?~~
	- May create issues down the road if importing recipes that don't match the units defined by ingredients, but could be dealt with through conversion.
	- Would ensure that entire database was using the same units so would be easier to do calculations if needed on multiple items.
- Start moving styling closer to StockCube brand
- Get something up on domain
	- sign up form?
- ~~Start working on user accounts~~
	- Complete [rails tutorial](https://www.railstutorial.org/book/updating_and_deleting_users#sec-updating_what_we_learned_in_this_chapter)
- Add description field to meals
- Rename meals to recipes
- Import Veggie recipes from `.exl` file into database
	- Figure out repeatable method to import [esha databases](https://www.esha.com/resources/additional-databases/)
- Figure out where to host database
- Order Ardunio/Raspberry Pi kit for physical prototyping
- Sponsorship?