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
- Units in database
	- ~~Move unit over to ingredient?~~
		- May create issues down the road if importing recipes that don't match the units defined by ingredients, but could be dealt with through conversion.
		- Would ensure that entire database was using the same units so would be easier to do calculations if needed on multiple items.
		- Esha databases contain many different unusual measures, convert on import?
			- Could convert on import to ensure same units used everywhere then retain old measures in db to use in recipe if needed?
- StockCube brand
	- ~~Start moving styling closer to StockCube brand~~
	- Logo needs recreating
	- Colours need defining
	- Create elements page to collect all elements together to be styled
	- HTML Components to be imported on different pages and present different data with same style
- Stockcub.es
	- Get something up on domain
		- sign up form?
- User accounts
	- ~~Start working on user accounts~~
	- Complete [rails tutorial](https://www.railstutorial.org/book/updating_and_deleting_users#sec-updating_what_we_learned_in_this_chapter)
- Importing XML into db
	- ~~Import Veggie recipes from `.exl` file into database~~
	- ~~Figure out repeatable method to import [esha databases](https://www.esha.com/resources/additional-databases/)~~
	- Figure out how to seed remote database with esha data
	- Figure out method to mark ingredients as vegetarian & vegan in database
	- Logic to present if recipe is vegetarian / vegan 
		- If all ingredients in a recipe are vegetarian then the recipe is vegetarian
- Cupboards functionality
	- Simple method of adding ingredients to cupboards with default weight and use by date
	- Joint (family) account to share cupboards?
- Recipes functionality
	- Method to favourite a set of recipes
	- Default recipes page would be user's favourite recipes, not a listing of all recipes
	- Method to share recipes between account?
- Ingredients functionality
	- Ingredients list should only be accessible by admins
	- Ingredients can be added by anyone but adding method should search through and present existing ingredients to ensure that user can see use existing ingredient if possible.
	- Should be method for admin to combine the user added ingredients with existing ingredients 
- Notifications
	- Notification method for telling user that food is going out of date
- Hosting
	- Figure out where to host database
- Physical devices
	- Order Ardunio/Raspberry Pi kit for physical prototyping
	- Figure out how physical device would update data in db, api call?
	- What happens if physical device records data but is not connected to a stock ingredient?
	- The user needs a method of reviewing all physical devices connected with account
- Sponsorship?