# ActiverecordReindex

Add Elasticsearch reindex option to ActiveRecord associations

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_reindex'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord_reindex

## Usage

To reindex associted records just add reindex: options to any ActiveRecord association.
Acceptable values are true, :async.

It will hook on:
1. record update
2. record destroy
3. record reindex

and reindex records reflected in given association.

Reindexing strategy will depend on specified reindex value.

If reindex: true specified than associated in given association records will be reindexed in the same time as
current record was updated\destroy\reindexed(Syncronously)

If reindex: :async specified - records will be reindexed asyncronously using ActiveJob as adapter.

## TODO

1. Add config for selecting reindex adapter.
2. Add config for selection asyncronous reindex queue.
3. Add config for selecting different job wrappers.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/activerecord_reindex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
