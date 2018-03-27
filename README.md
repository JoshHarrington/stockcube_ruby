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
Find all to dos on the [General tasks project](https://github.com/JoshHarrington/stockcube_ruby/projects/1) board

## Points to consider
- Are physical devices needed?
	- Order Ardunio/Raspberry Pi kit for physical prototyping
	- Figure out how physical device would update data in db, api call?
	- What happens if physical device records data but is not connected to a stock ingredient?
	- The user needs a method of reviewing all physical devices connected with account
- Sponsorship / Funding?
