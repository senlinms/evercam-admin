# evercam-admin
Rails Application for Admin Area for User &amp; Camera Management

| Name   | Evercam Admin Client  |
| --- | --- |
| Owner   | [@pbrudny](https://github.com/pbrudny)   |
| Dependencies Status   | [![Dependency Status](https://gemnasium.com/evercam/evercam-admin.svg)](https://gemnasium.com/evercam/evercam-admin)  |
| Code Climate   | [![Code Climate](https://codeclimate.com/github/evercam/evercam-admin/badges/gpa.svg)](https://codeclimate.com/github/evercam/evercam-admin)   |
| Travis Test   | [![Dependency Status](https://travis-ci.org/evercam/evercam-admin.svg?branch=master)](https://travis-ci.org/evercam/evercam-admin)   |
| Test Coverage  | [![Test Coverage](https://codeclimate.com/github/evercam/evercam-admin/badges/coverage.svg)](https://codeclimate.com/github/evercam/evercam-admin)   |
| Version  | 0.9  |
| Evercam API Version  | 1.0  |
| Licence | [AGPL](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-%28agpl-3.0%29) |

The best starting point for Evercam is http://www.evercam.io/open-source

After that, you'll want to go here: https://github.com/evercam/evercam-devops

Any questions, drop us a line: http://www.evercam.io/contact

## Setup
``
$ bundle install
``

Create ``database.yml`` based on ``database.yml.example``

Prepare database:

``
$ rake db:setup
``

## Running
Start server:

``
$ rails s
``

Visit ``localhost:3000``

Sign in as default admin using credentials from  ``db/seeds.rb``

``
email: admin@evercam.io
``

``
password: password1
``

## Testing
Integration tests:

``
$ spinach
``

Unit tests:

``
$ rspec
``
