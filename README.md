# nb_integration
Integration to enhance CREW's NationBuilder website.

# Components

## Ruby web service

It uses the [Roda framework](http://roda.jeremyevans.net/).

It follows the conventions for a Small Application [outlined in the Roda docs](http://roda.jeremyevans.net/rdoc/files/doc/conventions_rdoc.html).

## Elm web client

Front-end code that interacts with the web service. A NationBuilder web page must fetch it.

# Deployment

The app is deployed on Heroku. To deploy you must have access to the CREW Heroku account.

You will need the [Heroku CLI](https://devcenter.heroku.com/categories/command-line) for various server administration tasks. See Heroku's docs for more information.

# Development

The web service makes requests to the NationBuilder, and needs credentials for a specific nation. Namely it requires `NB_SLUG` and `NB_API_TOKEN` environment variables.

We use the [Dotenv](https://github.com/bkeepers/dotenv) gem in order to set environment variables.

Default values live in the file `.env`. Please *do not* commit secret credentials to this file.

Sometimes you may need to hit a real nation's API for testing purposes, so you will need to temporarily use real credentials. Place them in a file named `.env.local`. That filename is gitignored in this repository.

Example `.env.local`:

```
NB_SLUG=crew
NB_API_TOKEN=<a real API token>
```

We use the [Rerun](https://github.com/alexch/rerun) gem to automatically restart the app when files change. To run the web server:

```
rerun -- bundle exec puma -C config/puma.rb
```

Alternatively, if you have the [Heroku CLI](https://devcenter.heroku.com/categories/command-line) installed, you can use the `heroku local` command, but note that rerun has trouble restarting it so you lose the auto-reloading functionality.

```
heroku local web -p 3000
```

# Testing

To run the test suite:

```
rspec
```

## Integration Tests

The integration tests will make HTTP requests to the development server, so it must be running for the tests to work.

If you need to run the development server at a different location than http://localhost:3000 change the `config.integration_test_server` value in  `spec/spec_helper.rb`.
