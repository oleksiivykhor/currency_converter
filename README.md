# Currency Converter

Simple currency converter built on Sinatra and uses Redis as database.

## Installation/Usage

`bundle install`

`bundle exec sidekiq -r ./app/workers/rates_worker.rb`

`redis-server`

`shotgun`

and visit [localhost:9393](http://localhost:9393)
