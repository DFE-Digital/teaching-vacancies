# Teacher Vacancy Service (TVS)

[API Documentation](https://docs.teaching-vacancies.service.gov.uk)

## User accounts & data

Before you can log in to the application locally you will need a __DfE Sign-in__ and an __invitation to join Teaching
Vacancies__. Talk to the team to get these set up.

### Importing school data

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/)

```bash
rake data:schools:import
```
## Algolia indexing

We use [Algolia's](https://algolia.com) search-as-a-service offering to provide an advanced search experience for our
jobseekers. 

### Environment Variables 

```bash
ALGOLIA_APP_ID=<Get from API Keys on Algolia Dashboard>
ALGOLIA_SEARCH_API_KEY=<Get from API Keys on Algolia Dashboard>
ALGOLIA_WRITE_API_KEY=<Get from API Keys on Algolia Dashboard>
```

Use keys for one of the existing development sandboxes, or make new ones, if you are working locally.

### Quickstart

```ruby
  # To manually load an index with live records for the first time:
  Vacancy.reindex!
  # This now only loads records that are scoped `.live`

  # To update a live index with newly published records using minimal operations:
  Vacancy.update_index!

  # To remove records that expired yesterday:
  Vacancy.remove_vacancies_that_expired_yesterday!

  # To remove all expired vacancies. 
  Vacancy.index.delete_objects(Vacancy.expired.map(&:id))
  # You should generally avoid doing this as it will create a large number of unnecessary operations 
  # once these are being filtered out of the regular indexing operations.
```

Existing records will be updated so long as they continue to meet the [:listed?](app/models/vacancy.rb#280) conditions.

### Development

When developing with [Algolia](https://algolia.com) you will find that *non-production environments will not start if
you try to use the Algolia production app*. There are multiple Algolia `Development` apps available and you are free to
make more if you need them. Details and api keys for the existing ones are available on the Algolia dashboard. You can
also make as many more free-tier apps as you like for testing, dev, etc.  

If you do make new free-tier Algolia apps please make sure you include your name and/or ticket/PR numbers in the name so
we can keep track of these and clear them out occasionally. 

Let your colleagues know if you take over an existing development app to be sure you don't accidentally step on anyone's
toes. 

#### Note on Free-Tier Algolia Apps

Community Apps, which are free, do not have team functionality. This means that you will not be able to access the dashboard
for apps that other people have created and they will not be able to access the dashboard for yours. If you need to
share an app dashboard between multiple users create it using the `teachingjobs` account. 

This **only applies** to the `dev` (1RWSKBURHA - 'TVS DEV PAAS') and `staging` (CFWW19M6GM - 'TVS STAGING PAAS') shared 
apps and any community apps you want to create for your own use/development work. It also does not affect your ability to
use apps for which you have the API keys. It **only** stops you from viewing the dashboard for **community apps** you 
did not create. 

### Indexing live records

We originally started by indexing all records. It became apparent that this had unnecessary cost implications, so the
codebase was refactored to index only live (or `listed`) records. The [Algolia](https://algoliac.om) Rails plugin is
now set so it automatically updates existing live records if they change. 

NOTE: The default `#reindex!` method, added by the Algolia gem, has been overridden so it only indexes Vacancies records
that fall under the scope `#live`. This is to ensure that expired and unpublished records do not get accidentally added. 

## Running the tests

### Ruby 

This uses a standard `rspec` and `rubocop` stack. To run these locally:

```bash
bin/rake
```

## Troubleshooting

_I see Page Not Found when I log in and try to create a job listing_

Try importing the school data if you have not already. When your sign in account was created, it was assigned to a
school via a URN, and you may not have a school in your database with the same URN.

## Dependencies

### Baseline

```bash
Ruby 2.6.6
```

### Services

Make sure you have the following services configured and running on your development background:

 * [Postgresql](https://postgresql.org)
 * [Redis](https://redis.io)

### Test and development dependencies

 * [PhantomJS](https://phantomjs.org)

### Installation and setup

Once you have Postgresql running add a new user:

```bash
createuser --interactive --pwprompt
```

For running local development and test environments, you can safely grant the user superuser access when asked.  **DO
NOT** do this for production environments.

Feel free to use any other method you are familiar with for adding postgres users. This is only an example.

Next, copy `dotenv.sample` to `.env`, edit it and change:

```bash
DATABASE_URL=postgres://<user>:<password>@localhost/<desired-database-name>
```

Now, install your gem dependencies, then create and populate your database:

```bash
bundle
bundle exec rake db:create db:environment:set db:schema:load
```

Finally, run your tests:

```bash
bundle exec rake
```

If everything passes, you're ready to get to work.

### Misc

#### RSpec formatters - Fuubar

Fuubar is a fast-failing progress bar formatter for RSpec. I've added the gem, but know from experience it isn't to
everyone's taste. If you want to use it, either start RSpec with the formatter switch:

```bash
bundle exec rspec --format Fuubar
```

or add it to your global `~/.rspec`:

```bash
--format Fuubar
```
