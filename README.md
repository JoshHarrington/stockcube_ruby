# README

Welcome to this rudamentary prototype for the StockCube App

* Ruby version - 2.5.0  

I recommend using [Rbenv](https://github.com/rbenv/rbenv) to manage your Ruby environments and using [Homebrew](https://brew.sh/) to manage your packages (if you're on a Mac).  

If you're using Homebrew on Mac then you use it to install PostgresQL (the database type) with the command `brew install postgres` - there are many guides out there to explain this process in more detail eg [this one](https://gist.github.com/sgnl/609557ebacd3378f3b72)

## Steps to run
1. Pull down repo
2. Copy `.env.template` to create a new `.env` file and fill with your details
3. Run `bundle install` to install Gems
4. Run `rake db:create` to create the databases
5. Run `rake db:migrate` to migrate the databases
. Run `rake db:seed` to seed the databases with data (make sure you have the .env file setup first with a personal email, 6password and Rails environment variable)
7. Run `rails server` (or `rails s`) to run server
8. See app at [http://localhost:3000](http://localhost:3000)

## To dos
- Database seeding
	- Allow Seeds file to skip over existing database content, or overwrite, rather than resetting and reseeding each time
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
	- Check if ingredients added twice are actually used in the recipe in two different amounts? If yes then add the amounts together, assuming the unit is the same and update portion of relevant ingredient in recipe
	- Add new recipes into database
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
- Shopping list
	- ~~Create table for shopping list, owned by a particular user~~
	- ~~Join to recipes so that recipes can be added~~
		- ~~Shopping list should combine same (or similar?) ingredients into one item~~
	- Individual ingredients should be able to be added too ie bread, milk, eggs
	- Ready meals and snacks should be able to be added as an ingredient without a recipe (or portion?)
	- History of previous shopping list should exist and be reuseable
	- Ingredient amounts in shopping list should be able to change?
		- What if this impacts a recipe
		- Warning to user if they're about to remove (or reduce) an ingredient that will impact a recipe
	- Similar functionality to Cupboard - how much of a recipe have you already got in cupboards?
	- 'Keep' style functionality to tick off items in shopping list and see them struck-through under list
	- Shopping list should show all portions as totals for that ingredient
	- ~~Check if ingredients in shopping list already exist in Cupboard~~
- Recipes functionality
	- ~~Method to edit a recipes Ingredients and Portions~~
	- ~~Method to favourite a set of recipes~~
	- ~~Default recipes page would be user's favourite recipes, not a listing of all recipes~~
	- Search form on index page, pass value through to search page
	- Method to share recipes between account?
		- Sharing link to page
	- ~~**Should not** be able to get to recipe edit pages when not logged in~~
	- ~~Logic to present if recipe is vegetarian / vegan~~
		- ~~If all ingredients in a recipe are vegetarian then the recipe is vegetarian~~
		- Some ingredients are marked as not vegetarian / vegan when they should be - bad data, needs fixing
			- eg. Vinegar (Distilled)
	- Is there a need for a recipe search outside of cupboards?
		- User might start search in cupboard then want more options so need more general search, even if functionality the same
- Ingredients functionality
	- ~~Ingredients list should only be accessible by admins~~
	- ~~Ingredients can only be accessed by admins~~
	- Should be method for admin to combine the user added ingredients with existing ingredients 
	- ~~Only admins should be able to update an Ingredients details and characteristics~~
	- All users should be able to suggest a fix on an ingredient or recipe (?)
- Notifications
	- Notification method for telling user that food is going out of date
		- Email?
		- SMS?
		- Web Notifications?
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

