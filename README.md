Engine Light
============

### Simple dashboard for Code for America apps ###

Uses Mozilla Persona to handle login. The app will only allow users with CfA email addresses to login successfully

### Links to existing status endpoint implementations

#### Node.js
- [node-engine-light](https://github.com/jeremiak/node-engine-light) (middleware module)

#### Python
- [RecordTrac](https://github.com/codeforamerica/public-records/blob/master/public_records_portal/template_renderers.py) (search for "well_known_status")
- [BizFriendly API](https://github.com/codeforamerica/bizfriendly-api/blob/master/bizfriendly/routes.py) (search for "well-known")

#### Ruby
- [CityVoice](https://github.com/codeforamerica/cityvoice/blob/master/app/controllers/status_controller.rb)
- [Ohana API](https://github.com/codeforamerica/ohana-api/blob/master/app/controllers/status_controller.rb)
- [Human Services Finder](https://github.com/codeforamerica/human_services_finder/blob/master/app/controllers/status_controller.rb)
- [Trailsy Server](https://github.com/codeforamerica/trailsyserver/blob/master/app/controllers/status_controller.rb)

## Setup

Engine Light is a ruby on rails app

###Prerequisites

#### Git, Ruby 2.0.0+, Rails 4+, PostgreSQL

### Clone the app on your local machine:

    git clone git://github.com/codeforamerica/engine-light.git
    cd engine-light

### Bundle

    bundle install

### Setup DB

    rake db:setup

### Install foreman

    gem install foreman

See [Heroku Local Workstation Setup](https://devcenter.heroku.com/articles/getting-started-with-rails4#local-workstation-setup) for more info.

### Start the server

    foreman start
