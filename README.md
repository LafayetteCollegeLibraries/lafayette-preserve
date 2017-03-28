# LafayettePreserve
[![Build Status](https://travis-ci.org/LafayetteCollegeLibraries/lafayette-preserve.svg?branch=master)](https://travis-ci.org/LafayetteCollegeLibraries/lafayette-preserve) [![Coverage Status](https://coveralls.io/repos/github/LafayetteCollegeLibraries/lafayette-preserve/badge.svg?branch=master)](https://coveralls.io/github/LafayetteCollegeLibraries/lafayette-preserve?branch=master) [![Stories in Ready](https://badge.waffle.io/LafayetteCollegeLibraries/lafayette-preserve.svg?label=ready&title=Ready)](http://waffle.io/LafayetteCollegeLibraries/lafayette-preserve)

A [Sufia](http://sufia.io/) implementation for curating and preserving digital resources for the Lafayette College Libraries.

## Prerequisites

As it is based upon Sufia, LafayettePreserve requires the following software to work:

1. Solr version >= 5.x
1. [Fedora Commons](http://www.fedora-commons.org/) digital repository version >= 4.5.1
1. A SQL RDBMS (MySQL, PostgreSQL), though **note** that SQLite will be used by default if you're looking to get up and running quickly
1. [Redis](http://redis.io/), a key-value store
1. [ImageMagick](http://www.imagemagick.org/) with JPEG-2000 support
1. [FITS](#characterization) version 0.8.x (0.8.5 is known to be good)
1. [LibreOffice](#derivatives)

**NOTE: If you do not already have Solr and Fedora instances you can use in your development environment, you may use hydra-jetty (instructions are provided below to get you up and running quickly and with minimal hassle).**

### Support for Controlled Vocabulary Management
In addition to extending the standard support for the Sufia feature set, we currently only  support [Blazegraph](https://www.blazegraph.com/) in order to manage controlled vocabularies and terms as linked data.

#### Architecture and Implementation
Currently, LafayettePreserve borrows heavily from the functionality supported by [the Controlled Vocabulary Manager from Oregon Digital](https://github.com/OregonDigital/ControlledVocabularyManager).

### Characterization

1. Go to http://projects.iq.harvard.edu/fits/downloads and download a copy of FITS (see above to pick a known working version) & unpack it somewhere on your machine.
1. Mark fits.sh as executable: `chmod a+x fits.sh`
1. Run `fits.sh -h` from the command line and see a help message to ensure FITS is properly installed
1. Give your Sufia app access to FITS by:
    1. Adding the full fits.sh path to your PATH (e.g., in your .bash_profile), **OR**
    1. Changing `config/initializers/sufia.rb` to point to your FITS location:  `config.fits_path = "/<your full path>/fits.sh"`

### Derivatives

Install [LibreOffice](https://www.libreoffice.org/). If `which soffice` returns a path, you're done. Otherwise, add the full path to soffice to your PATH (in your `.bash_profile`, for instance). On OSX, soffice is **inside** LibreOffice.app. Your path may look like "/<your full path to>/LibreOffice.app/Contents/MacOS/"

You may also require [ghostscript](http://www.ghostscript.com/) if it does not come with your compiled version LibreOffice. `brew install ghostscript` should resolve the dependency on a mac.

**NOTE**: derivatives are served from the filesystem in Sufia 7, which is a difference from earlier versions of Sufia.

## Environments

Note here that the following commands assume you're setting up Sufia in a development environment (using the Rails built-in development environment). If you're setting up a production or production-like environment, you may wish to tell Rails that by prepending `RAILS_ENV=production` to the commands that follow, e.g., `rails`, `rake`, `bundle`, and so on.

## Ruby

First, you'll need a working Ruby installation. You can install this via your operating system's package manager -- you are likely to get farther with OSX, Linux, or UNIX than Windows but your mileage may vary -- but we recommend using a Ruby version manager such as [RVM](https://rvm.io/) or [rbenv](https://github.com/sstephenson/rbenv).

We recommend either Ruby 2.3 or the latest 2.2 version.

# Running LafayettePreserve

## Clone the Git Repository
``
git clone https://github.com/LafayetteCollegeLibraries/lafayette-preserve.git
``

## Install the Gem Dependencies
``
bundle install
``

## Migrate the Rails Database Schema
``
rake db:migrate
``

# Testing LafayettePreserve

Currently, one must perform the following steps manually using separate terminals:

## Start Solr
``
solr_wrapper -p 8985 -d solr/config/ --collection_name hydra-test
``

## Start fcrepo4
``
fcrepo_wrapper -p 8986 --no-jms
``

## Start Blazegraph
``
rake triplestore_adapter:blazegraph:reset
``

## Execute the Test Suites
``
TRIPLESTORE_URL='http://localhost:9999/blazegraph/namespace/test/sparql' rake spec
``

# Acknowledgments

This software has been developed by [Digital Scholarship Services](https://digital.lafayette.edu/) of the [Lafayette College Libraries](https://library.lafayette.edu/), building heavily upon the collaborative efforts of all members within the [Project Hydra community](http://projecthydra.org/).

# License
GPL-3.0
