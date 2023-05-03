# Stockcubes

This is the now deprecated and no longer maintained prototype for the Stockcubes application

## Project purpose

The application was design to help users manage their food at home, with inventory systems, automatic shopping list creation and meal planning.

## Tech stack

The code of the application is a mix of Ruby on Rails for the backend and React components for the frontend

* Ruby version >=2.5.0

## Running the project

I recommend using [Homebrew](https://brew.sh/) to manage your packages and Ruby environment (if you're on a Mac).

If you're using Homebrew on Mac then you use it to install PostgresQL (the database type) with the command `brew install postgres` - there are many guides out there to explain this process in more detail eg [this one](https://gist.github.com/sgnl/609557ebacd3378f3b72)

## Steps to run
1. Pull down repo
2. Copy `.env.template` to create a new `.env` file and fill with your details
3. Run `bundle install` to install Gems
4. Run `rake db:create` to create the databases
5. Run `rake db:migrate` to migrate the databases
. Run `rake db:seed` to seed the databases with data (make sure you have the .env file setup first with a personal email, password and Rails environment variable)
7. Run `rails server` (or `rails s`) to run server
8. See app at [http://localhost:3000](http://localhost:3000)

## Steps to run with [Browser Sync](https://browsersync.io)
1. Run the app as described above with `rails server` (or `rails s`)
2. Open a new terminal window
3. Naviagte to the '/browser-sync' folder inside this repo
4. For first use, run `npm install && npm start`
5. At all other times, only run `npm start`
6. Use proxy address provided, shown in terminal window

## License

This project is licensed under the terms of the MIT license.
