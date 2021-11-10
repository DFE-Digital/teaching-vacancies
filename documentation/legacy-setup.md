# Legacy local application setup

> These notes formed part of the README before we moved towards using devcontainers for development.
> They'll be kept here for a while until our devcontainer workflow has fully been bedded in and we
> decide we don't need them anymore.

## Setup

Welcome! :tada: :fireworks: :tiger:

By now you should be [onboarded](/documentation/onboarding.md).

The first thing to do is to install the required development tools. If you are on a Mac, this [script](https://github.com/thoughtbot/laptop) will install Homebrew, Git, asdf-vm, Ruby, Bundler, Node.js, npm, Yarn, Postgres, Redis and other useful utilities.

Then, clone the project with SSH:

```bash
git clone git@github.com:DFE-Digital/teaching-vacancies.git
```

If you are on a new device, remember to [generate a new SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

### Dependencies

* [Ruby](https://www.ruby-lang.org)
* [NodeJS](https://nodejs.org)
* shared-mime-info (installed using Homebrew or other package manager of your choice, the
  `mimemagic` gem depends on this)

A tool like [asdf-vm](https://asdf-vm.com) can help you install the required versions of Ruby and Node.js.
Current versions that match production ones are specified in [.tool-versions](/.tool-versions).

If asdf-vm is installed correctly, from the project repository you can just execute:

```bash
asdf install
```

If `asdf install` fails with the below message, and you are on a Mac, install [GPG Suite](https://gpgtools.org/).

```
You must install GnuPG to verify the authenticity of the downloaded archives before continuing with the install: https://www.gnupg.org/
```

### Services

Make sure you have the following services configured and running on your development background:

* [PostgreSQL](https://www.postgresql.org)
* [Postgis](https://postgis.net/install/)
* [Redis](https://redis.io)

If using Homebrew to install PostgreSQL, run `brew services start postgresql` in order to have `launchd` start PostgreSQL and restart whenever you log in.

### ChromeDriver

To install
```bash
brew install --cask chromedriver
```

To update
```bash
brew upgrade --cask chromedriver
```

On macOS you might need to "un-quarantine" chromedriver too
```bash
which chromedriver
xattr -d com.apple.quarantine /path/to/chromedriver
```

### Install dependencies

#### Install Ruby dependency libraries

```bash
bundle
```

Install the version of Bundler that created the lockfile if prompted to do so.

#### Install Javascript dependency libraries

```bash
yarn
```

## Troubleshooting

* I see Page Not Found when I log in and try to create a job listing.

Try [seeding the database](https://github.com/DFE-Digital/teaching-vacancies#seed-the-database) (quick) or [importing the school data](#gias-data-schools-trusts-and-local-authorities) (slow) if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

---

## Misc

### Getting production-like data for local development

To get sanitised production-like data for local development, first log in to AWS with the ReadOnly role. To do so, follow the instructions here: [AWS Login](/documentation/aws-roles-and-cli-tools.md#log-in-to-the-aws-console-with-aws-vault).

Once logged in, go to S3 >  530003481352-tv-db-backups > sanitised. Then click the checkbox next to the backup you want (the names of the backups will include dates) and click "Download".

Then, unzip the file and load it into your local database like so:

```bash
  psql tvs_development < <path to unzipped .sql backup file>
```

### Integration between Jira and Github

The integration allows to see the status of development from within the jira issue. You can see the
status of branches, commits and pull requests as well as navigate to them to show the detail in Github.

To enable this, the following formatting must be used:
- Branch: Prefix with the issue id. Ex: `TEVA-1155-test-jira-github-integration`
- Commit: Prefix with the issue id between square bracket. Ex: `[TEVA-1155] Update Readme`
- Pull request: Prefix with the issue id between square bracket. If the branch was prefixed correctly,
this should be automatically added for you. Ex: `[TEVA-1155] Document Jira-Github integration`

The branch, commit or pull request will then appear in the `Development` side panel within the issue.
