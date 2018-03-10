# README

Welcome to this rudamentary prototype for the StockCube App

* Ruby version - 2.5.0  

I recommend using [Rbenv](https://github.com/rbenv/rbenv) to manage your Ruby environments and using [Homebrew](https://brew.sh/) to manage your packages (if you're on a Mac).  

If you're using Homebrew on Mac then you use it to install PostgresQL (the database type) with the command `brew install postgres` - there are many guides out there to explain this process in more detail eg [this one](https://gist.github.com/sgnl/609557ebacd3378f3b72)

## Steps to run
1. Pull down repo
2. Run `bundle install` to install Gems
3. Run `rake db:create` to create the databases
4. Run `rake db:migrate` to migrate the databases
5. Run `rake db:seed` to seed the databases with data (make sure you have the .env file setup first with a personal email, password and Rails environment variable)
6. Run `rails server` (or `rails s`) to run server
7. See app at [http://localhost:3000](http://localhost:3000)

## To dos
- Units in database
	- ~~Move unit over to ingredient?~~
		- **BUG** - Portions need separate unit for situations where recipe requires different measure of ingredient eg carrots, recipe 16 & 120
		- May create issues down the road if importing recipes that don't match the units defined by ingredients, but could be dealt with through conversion.
		- Would ensure that entire database was using the same units so would be easier to do calculations if needed on multiple items.
		- Esha databases contain many different unusual measures, convert on import?
			- Could convert on import to ensure same units used everywhere then retain old measures in db to use in recipe if needed?
	- ~~Abbreviations provided for all possible units~~
- StockCube brand
	- ~~Start moving styling closer to StockCube brand~~
	- Logo needs recreating
	- Colours need defining
	- Create elements page to collect all elements together to be styled
	- HTML Components to be imported on different pages and present different data with same style
	- Animations for logo on hover?
		- Little person inside cube could open front of cube and put 'busy' sign on the front then close door 
		- Little person could peek out if logo only hovered for a short time 
		- Little person could present food animation or suggest good recipe 
- Stockcub.es
	- Get something up on domain
		- sign up form?
- User accounts
	- ~~Start working on user accounts~~
	- Complete [rails tutorial](https://www.railstutorial.org/book/updating_and_deleting_users#sec-updating_what_we_learned_in_this_chapter)
	- Users should be able to set which units they want to use
		- Settings tables that belongs_to user
- Importing XML into db
	- ~~Import Veggie recipes from `.exl` file into database~~
		- ~~Import portions of ingredients~~
	- ~~Figure out repeatable method to import [esha databases](https://www.esha.com/resources/additional-databases/)~~
	- ~~Figure out method to mark ingredients as vegetarian & vegan in database~~
	- ~~Figure out how to seed remote database with esha data~~
		- ~~Need to switch over to PSQL from SQLite3, see [SO question]~~(https://stackoverflow.com/questions/15371394/rails-populate-heroku-database-with-development-sqlite3-data)
- Cupboards functionality
	- Simple method of adding ingredients to cupboards with default weight and use by date
	- ~~All Cupboards should belong to an individual user~~
	- How to share cupboards between users?
		- ^^ `has_many` vs `has_one`?
	- Recipe search should be prefilled based on (common and searchable) ingredients in cupboards
		- Search should allow for adding of ingredients not currently in cupboards
- Stocks functionality
	- ~~All Stock should belong to an individual user~~
	- How to share stock between users?
- Recipes functionality
	- ~~Method to edit a recipes Ingredients and Portions~~
	- ~~Method to favourite a set of recipes~~
	- Default recipes page would be user's favourite recipes, not a listing of all recipes
	- Method to share recipes between account?
	- **Should not** be able to get to recipe edit pages when not logged in
	- ~~Logic to present if recipe is vegetarian / vegan~~
		- ~~If all ingredients in a recipe are vegetarian then the recipe is vegetarian~~
		- Some ingredients are marked as not vegetarian / vegan when they should be - bad data, needs fixing
			- eg. Vinegar (Distilled)
	- Is there a need for a recipe search outside of cupboards?
		- User might start search in cupboard then want more options so need more general search, even if functionality the same
- Ingredients functionality
	- ~~Ingredients list should only be accessible by admins~~
	- Ingredients can be added by anyone but adding method should search through and present existing ingredients to ensure that user can see use existing ingredient if possible.
	- Should be method for admin to combine the user added ingredients with existing ingredients 
	- Only admins should be able to update an Ingredients details and characteristics
	- All users should be able to suggest a fix on an ingredient or recipe
- Notifications
	- Notification method for telling user that food is going out of date
		- Email?
		- SMS?
- Hosting
	- Figure out where to host database
		- Herkou?
		- AWS?
- Physical devices
	- Order Ardunio/Raspberry Pi kit for physical prototyping
	- Figure out how physical device would update data in db, api call?
	- What happens if physical device records data but is not connected to a stock ingredient?
	- The user needs a method of reviewing all physical devices connected with account
- Sponsorship / Funding?

