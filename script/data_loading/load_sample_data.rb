# this script will populate the app with fake data for users, accounts, and people
# it creates 4 users
# then 100 accounts, each with between 3 and 10 people

usa_country = Locations::Country.find_by(alpha_2: "US")
won_stage = DealStage.find_by_name("Closed Won")
lost_stage = DealStage.find_by_name("Closed Lost")

def generate_valid_phone_number(country)
  valid = false

  pn = nil

  until valid
    pn = PhoneNumber.new(number: Faker::PhoneNumber.phone_number, country: country)

    valid = pn.valid?
  end

  pn
end

def create_reminder(related_to, earliest_occurring_at: nil, latest_occurring_at: nil, mark_complete: false, assigned_to:)
  related_to = Array.wrap(related_to)

  earliest_at = earliest_occurring_at || related_to.map(&:created_at).max

  latest_at = latest_occurring_at || (Date.today + 6.months)

  occurring_at = Faker::Date.between(from: earliest_at, to: latest_at)

  complete =  if mark_complete
                true
              elsif occurring_at > Date.today
                false
              elsif occurring_at < Date.today.prev_month
                true
              else
                # in the last month
                # mark complete ~75% of the time
                rand(1..100) <= 75 
              end

  title = "Discuss #{Faker::Commerce.product_name}"

  notes = Faker::Lorem.sentences(number: rand(1..10)).join(" ")

  created_at = Faker::Time.between(from: occurring_at - 30.days, to: occurring_at.prev_day)

  r = Reminder.new(
    reminder_subjects: related_to.map(&:reminder_subject),
    occurring_at: occurring_at,
    type: ReminderType.random,
    title: title,
    notes: notes,
    complete: complete,
    assigned_to: assigned_to,
    created_at: created_at,
    created_by: assigned_to
  )

  r.save!
end

def generate_deal_amount
  # 75% chance that the deal is >= $10k < $30k
  # 25% chance that it is > $30k and <= $100k

  r = rand(1..100)

  if r <= 75
    (10_000..30_000).step(1_000).to_a.sample
  else
    (30_000..100_000).step(5_000).to_a.sample
  end
end

def generate_deal_name(account)
  "#{account.name} #{Faker::Commerce.product_name}"
end

def generate_deal_with_reminders(stage)
  account = Account.random

  deal_created_at = Faker::Time.between(from: Date.new(2023, 1, 1), to: Date.yesterday)

  deal = Deal.new(
    account: account,
    owner: account.owner,
    description: Faker::Lorem.sentences(number: rand(5..12)).join(" "),
    stage: stage,
    source: AccountLeadSource.random,
    name: generate_deal_name(account),
    amount: generate_deal_amount,
    created_at: deal_created_at,
    created_by: account.owner
  )

  earliest_close_date = deal.closed? ? deal_created_at : Date.tomorrow
  latest_close_date = deal.closed? ? Date.yesterday : Date.today + 6.months

  deal.close_date = Faker::Date.between(from: earliest_close_date, to: latest_close_date)

  deal.save!

  # create a few reminders on the deal
  # make sure the reminder is set to occur while the deal was open
  # and if the deal is closed, always mark it as complete
  #
  # include a random 1-4 people on the reminder
  rand(3..6).times do
    people = account.people.random(rand(1..4))

    related_to = [deal, people].flatten

    create_reminder(
      related_to,
      earliest_occurring_at: deal_created_at,
      latest_occurring_at: deal.close_date,
      mark_complete: deal.closed?,
      assigned_to: deal.owner
    )
  end
end



ActiveRecord::Base.transaction do

  puts "Removing existing data..."

  ReminderLink.delete_all
  Reminder.delete_all
  ReminderSubject.delete_all
  Deal.delete_all
  Person.delete_all
  Account.delete_all
  User.where(admin: false).destroy_all

  puts "Completed!"

  puts "Creating new sample data..."  

  users_domain = "example.com"

  puts "Creating users..."

  4.times do

    # create a new user with the following attributes:
    #   first_name: random first name
    #   last_name: random last name
    #   email_address: first_name_last_name@users_domain
    #   password_digest: digest of random password

    first_name = Faker::Name.first_name
    last_name = Faker::Name.last_name

    u = User.create!(
      first_name: first_name,
      last_name: last_name,
      email_address: Faker::Internet.email(name: "#{first_name} #{last_name}", domain: users_domain),
      password_digest: BCrypt::Password.create(Faker::Internet.password)
    )
  end

  puts "Creating accounts..."

  100.times do

    # create a new account with the following attributes:
    #   name: random company name
    #   assigned_to: random user from above
    #   billing_address: random address
    #   shipping_address: random address
    #   phone_number: random phone number in company country
    #   description: random description based on company attributes
    #   annual_revenue: random number between 1,000,000 and 10,000,000, in increments of 1M
    #   number_of_employees: random number between 10 and 100,000, in increments of 10
    #   industry: random industry from industries table
    #   website: random website
    #   incorporation_date: random date between 1950-01-01 and today
    #   account_source: random AccountLeadSource
    #   created_date: random date after incorporation_date and 2024-01-01
    #   created_by: same random user as assigned_to


    # set up first
    # choose an assigned user
    # company name
    # company domain (based on company name)

    company_name = Faker::Company.name
    company_domain = Faker::Internet.domain_name(domain: company_name.dasherize.gsub("-", ""))
    country = Locations::Country.random

    state_abbrev = Faker::Address.state_abbr
    state_region = Locations::StateRegion.find_by(country_short_code: "US", alpha_code: state_abbrev)

    industry = Industry.random

    incorporation_date = Faker::Date.between(from: Date.new(1950, 1, 1), to: Date.today)

    num_employees = (10..100_000).step(10).to_a.sample

    company_description = <<~DESC.squish
      #{company_name} is a #{state_region.name}-based company in the #{industry.name} industry. It was founded
      in #{incorporation_date.year} and has grown to #{ActiveSupport::NumberHelper.number_to_delimited(num_employees)} employees. The company is widely respected
      as the go-to company for customers who want to #{Faker::Company.bs}.
    DESC

    address = Address.new(
      street: Faker::Address.street_address,
      city: Faker::Address.city,
      state_region: state_region,
      country: usa_country,
      postal_code: Faker::Address.postcode
    )

    min_created_date = [incorporation_date, Date.new(2023, 1, 1)].max

    assigned_to_user = User.random

    acct = Account.new(
      name: company_name,
      owner: assigned_to_user,
      billing_address: address,
      shipping_address: address,
      phone_number: generate_valid_phone_number(usa_country),
      description: company_description,
      annual_revenue: rand(1_000_000..10_000_000_000).step(5_000_000).to_a.sample,
      number_of_employees: num_employees,
      industry: industry,
      website: company_domain,
      incorporation_date: incorporation_date,
      account_source: AccountLeadSource.random,
      created_at: Faker::Date.between(from: min_created_date, to: Date.today)
    )

    rand(3..10).times do

      # create a new person with the following attributes:
      #   account: should be the new account from above
      #   assigned_to: random user
      #   first_name: should be a random first name
      #   last_name: should be a random last name
      #   email_address: should be first_name.last_name@company_domain
      #   job_title: random job title
      #   address: should be a random address in the account's country
      #   phone_number: should be a random phone number for the account's country
      #   assigned_to: random user from above
      #   created_by: random user from above
      #   last_updated_by: random user from above

      person_address = Address.new(
        street: Faker::Address.street_address,
        city: Faker::Address.city,
        state_region: state_region,
        country: usa_country,
        postal_code: Faker::Address.postcode
      )

      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name

      person = Person.new(
        account: acct,
        first_name: first_name,
        last_name: last_name,
        email_address: Faker::Internet.email(name: "#{first_name} #{last_name}", domain: company_domain),
        job_title: Faker::Job.title,
        address: person_address,
        phone_number: generate_valid_phone_number(usa_country),
        owner: assigned_to_user,
        created_by: assigned_to_user,
        last_updated_by: assigned_to_user,
        created_at: Faker::Date.between(from: min_created_date, to: Date.today)
      )
    end

    acct.save!
  end

  # create a bunch of fake deals
  #
  # deals need the following attributes:
  #   account
  #   owner: owner of the account
  #   close_date
  #   stage
  #   source
  #   name
  #   description
  #   amount: between 

  puts "Creating deals..."

  # create 50 past won deals
  50.times do
    generate_deal_with_reminders(won_stage)
  end

  # create 100 past lost deals
  100.times do
    generate_deal_with_reminders(lost_stage)
  end
  
  # create 25 open deals
  25.times do
    stage = DealStage.where.not(name: ["Closed Won", "Closed Lost"]).random
    generate_deal_with_reminders(stage)
  end



  # create a bunch of fake reminders
  #
  # reminders need the following attributes:
  #   logged_to: account or person reminder is being attached to
  #   occurring_at: random time between the account created date and 6 months from now
  #   type: random ReminderType
  #   complete: if occurred more than one month ago, true, if in the last month 75/25 true/false, if in future then false
  #   assigned_to: logged_to record owner
  #   created_by: logged_to record owner
  #   last_updated_by: logged_to record owner

  puts "Creating reminders..."

  # create fake reminders on accounts
  Account.all.includes(:reminder_subject).each do |acct|
    rand(2..5).times do
      create_reminder(acct, assigned_to: acct.owner)
    end
  end

  # create fake reminders on people
  Person.all.includes(:reminder_subject).each do |person|
    rand(2..5).times do
      create_reminder(person, assigned_to: person.owner)
    end
  end

end

puts "Finished!! Your sample data is now ready"