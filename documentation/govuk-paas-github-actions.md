# Notes on GOVUK PaaS Github Actions Implementation

## Background

As the build process migrates to GOVUK PaaS, Continuous Integration (CI) needs to be set up. 
A preliminary workflow was set up using Github Actions.

## Github Workflows Overview

Workflow files in `.github/workflows` contain the configuration to execute jobs based on various triggers.
A typical workflow might execute lint check and test jobs on push events for all branches, and execute a 
build and deploy job for pushes to master. The example workflows currently only execute on the spike branch.
Github Actions uses secrets for authentication etc and these are stored in the settings of the repo on Github.

## Lint check
`linter.yml`:
  1. Checkout the code 
  2. Set up Ruby
  3. Install packages/use cache
  4. Execute Rubocop lint checking on the codebase `bundle exec rubocop`

## Tests
`test.yml`:
  - Uses services for postgres and elasticsearch
  1. Checkout the code 
  2. Set up Ruby/Node
  3. Install packages/use cache
  4. Set up test database
  5. Run tests `bundle exec rake`

## Build
`build.yml`:
  1. Checkout code
  2. Install CloudFoundry command line interface
  3. Login to CloudFoundry
  4. Create postgres, redis, elasticsearch services
  5. Deploy the app `cf push`

