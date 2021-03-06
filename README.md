# nb_integration
Integration to enhance CREW's NationBuilder website.

<!-- toc -->

- [Components](#components)
  * [Ruby web service](#ruby-web-service)
  * [Elm web client](#elm-web-client)
- [Deployment](#deployment)
  * [Environment variables](#environment-variables)
  * [Buildpacks](#buildpacks)
  * [Continuous Deployment](#continuous-deployment)
  * [NationBuilder Setup](#nationbuilder-setup)
    + [App registration and installation](#app-registration-and-installation)
    + [How to create a survey and make it available to the API](#how-to-create-a-survey-and-make-it-available-to-the-api)
- [Development and Testing](#development-and-testing)
  * [Web Service](#web-service)
    + [Prerequisites](#prerequisites)
    + [Verify Environment](#verify-environment)
    + [Run the test suite](#run-the-test-suite)
    + [Run the development server](#run-the-development-server)
    + [Console](#console)
    + [Making changes](#making-changes)
  * [Frontend Client](#frontend-client)
    + [Prerequisites](#prerequisites-1)
    + [Development](#development)
    + [Run tests](#run-tests)
- [Documentation](#documentation)

<!-- tocstop -->

# Components

## Ruby web service

It uses the [Roda framework](http://roda.jeremyevans.net/).

It follows the conventions for a Small Application [outlined in the Roda docs](http://roda.jeremyevans.net/rdoc/files/doc/conventions_rdoc.html).

## Elm web client

Front-end code that interacts with the web service. A NationBuilder web page must fetch it.

# Deployment

We host the app on Heroku. To deploy you must have access to the CREW Heroku account.

You will need the [Heroku CLI](https://devcenter.heroku.com/categories/command-line) for various server administration tasks. See Heroku's docs for more information.

Staging: https://staging-nb-integration.herokuapp.com/
Production: https://nb-integration.herokuapp.com/

## Environment variables

Consult the Heroku settings page with the config variable values and the references to them in the source code for the comprehensive truth. With that said, here is a sampling:

* `HTTP_PROTOCOL` and `DOMAIN_NAME`: used by the web service to compute its own URLs, for example https://api.climatecrew.org/oauth/callback
* `DATABASE_URL`: managed by Heroku, the URL to connect to the Postgres DB backing the web service

## Buildpacks

The app requires the heroku/nodejs and heroku/ruby buildpacks, in that order. We use node to compile the Elm client app on production. `package.json` includes a post-install script to prep the app JS. We do not keep the compiled app in version control, because it would be a large file that slow down git clones, and would add noise to `git grep` results.

The last Heroku buildpack determines the process type of the deployed application. Therefore we need it to be heroku/ruby in order to run the web service.

## Continuous Deployment

We have a workflow defined in [CircleCI](https://circleci.com) that runs the tests. You will need access to the [climatecrew](https://circleci.com/gh/climatecrew) team in CircleCI.

When you push the `master` branch Circle runs the test suite, and Heroku listens to webhook notifications from Github and will deploy the *staging* app if the tests pass.

We have a Heroku pipeline, crew-1, to deploy staging and then production. To deploy production login to Heroku, go to the [pipeline](https://dashboard.heroku.com/pipelines/6bf6f14d-d2bf-4763-93df-b09a2d1da91f), and promote staging to production. As a rule, we should only do this after click-testing that the latest staging deploy works in the staging nation, [skarger.nationbuilder.com](https://skarger.nationbuilder.com).

Because this app integrates with a NationBuilder website, deploys sometimes require a coordinated change to the web page that loads this app's client, which you do via the nation's control panel. As a manual process this is error prone. We can avoid problems with the following steps:

  * Always ensure that the app works on the actual staging NationBuilder website.
  * Make notes of the manual changes required within the NationBuilder control panel while working them out in staging.
  * When practical, make backwards-compatible changes to this app so that deploying it does not need to happen in lock-step with the NB website edits.



## NationBuilder Setup

[NationBuilder developer docs](https://nationbuilder.com/developers)
### App registration and installation

We need to do the following as a one-time setup. It is based on the [API Quickstart](https://nationbuilder.com/api_quickstart) guide.

1. Register the app in our NationBuilder nation, crew.nationbuilder.com. An admin of that nation must go to Settings -> Developer -> Register app and enter the required details.
2. A logged-in admin of crew.nationbuilder.com must install the app.

You will only need to re-do these steps if a CREW admin deletes and/or uninstalls this app.

To repeat, registering and installing are different actions. CREW owns and provides this app so CREW is the only nation that registers it. A nation that wants to use the app's features installs it. In our case the sole intended user is the same nation, crew.nationbuilder.com.

A nation that registers an app can choose to make it available for other nations to install so that they too can use its features. That is not our intent for this particular app, so we do not make it publicly available in the registration step. We intend CREW to be the only nation that installs it.

By virtue of an admin installing it in crew.nationbuilder.com, the app will obtain an API access token. It uses that token to authenticate when making requests to the NationBuilder API on behalf of CREW.

### How to create a survey and make it available to the API

1. Go to People -> More -> Surveys (https://crew.nationbuilder.com/admin/surveys)
  Click New Survey
  * Example name: Climate Preparedness Event Planning
  * Create a single question at minimum:
    * comments_questions
    * Any comments or questions about your event idea?
    * Format: text

2. Make an *unlisted* web page in NB of type Survey. The new survey must be associated with a web page to be accessible to the API. It is helpful to make it a sub-page of a page related to this survey. Example:

  * page slug: event_planning_survey
  * page type: survey
  * Do not include in top nav
  * Select the previously created survey
  * Save

3. The survey ID and question ID must be known to the nb_integration app.
    In Heroku, set environment variables with the relevant values.
    We could do this differently, like by storing those values in the DB, or retrieving from the /surveys API and parsing out from the response. Environment variables were expedient for a one-off survey.


# Development and Testing

## Web Service

### Prerequisites

* You need Postgres installed locally.
* You need Ruby installed locally, and the bundler gem.

Install dependencies:

```
bundle install
```

Prepare the development database:

```
rake db:setup # aka rake db:development:setup
```

Prepare the test database:

```
rake db:test:setup
```

### Verify Environment

In production we use Heroku config variables to set the environment variables, but locally we use the [Dotenv](https://github.com/bkeepers/dotenv) gem.

At first you should not need to change what is stored in this repo, but in case you do here are the details:

Default values live in the file `.env`. Please *do not* commit secret credentials to this file.

Sometimes you may need to temporarily use real credentials. Place them in a file named `.env.local`. That filename is gitignored in this repository.

Finally any environment variables that differ between development and test should be set in `.env.development.local` and `.env.test.local`.

### Run the test suite

```
rake # by default runs the test suite

# OR run the suite directly:

rspec

# OR run a specific test file
rspec spec/integration/home_page_spec.rb
```

### Run the development server

We use the [Rerun](https://github.com/alexch/rerun) gem to automatically restart the app when files change. To run the web server:

```
rerun -- bundle exec puma -C config/puma.rb
```

Alternatively, if you have the [Heroku CLI](https://devcenter.heroku.com/categories/command-line) installed, you can use the `heroku local` command, but note that rerun has trouble restarting it so you lose the auto-reloading functionality.

```
heroku local web -p 3000
```

### Console

Run `bin/console` to access a command line client. It is a wrapper around Sequel's [bin/sequel utility](http://sequel.jeremyevans.net/rdoc/files/doc/bin_sequel_rdoc.html).

### Making changes

Overall you should consult the documentation for:

* The [Roda](http://roda.jeremyevans.net/) web framework
    * [Project structure conventions](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html)
* The [Sequel](http://sequel.jeremyevans.net/) database toolkit
    * Guide to [database migrations](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html)

Please update and enhance the RSpec tests when editing the functionality.

## Frontend Client

### Prerequisites

* You need node and npm installed locally. See the engines section in `package.json` for the current node version.
* You need [Yarn](https://yarnpkg.com/) installed locally.
* You need [Elm](http://elm-lang.org/).
    * `package.json` installs Elm via NPM, because we need it to compile in CircleCI and Heroku. However you can also install Elm with a platform-specific installer.

Install dependencies:

```
yarn install

yarn global add elm-test
```

### Development

Make changes to .elm files, and compile:

```
yarn
```

View at [http://localhost:3000/app](http://localhost:3000/app). The client is intended to be embedded on a NationBuilder website page, but for testing we directly serve a basic page with the client.

### Run tests

```
elm-test
```

# Documentation

If you update this README, update the table of contents by running:

```
yarn run markdown-toc -i README.md
```
