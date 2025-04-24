# README

To get the application up and running:

* Make sure you have Postgres installed (the app uses some functionality that is only written for use with pg at the moment)

* Make any necessary adjustments to `database.yml`

* Run `rails db:create` and `rails db:migrate` to set up the database

* Run `rails db:seed` to seed the database with some important initial data

* If you also want to populate the application with sample data for Accounts, Deals, People, and Reminders, then run `rails runner script/data_loading/load_sample_data.rb`

* Open up a console and create a new user for yourself. Best to also make yourself an admin user

```ruby
u = User.create!(
  first_name: <your_first_name>,
  last_name: <your_last_name>,
  email_address: <your_email>,
  password: <your_password>,
  admin: true
)
```

Once you've done the above, you should be good to start exploring the app!
