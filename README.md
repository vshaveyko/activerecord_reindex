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

## Prerequisites

  0. ActiveRecord 5.0+
  1. `elasticsearch-model` gem installed
  2. model that will be reindexed inherits from Elasticsearch::Model
  3. model is inherited from ActiveRecord::Base

## Usage

  To reindex associted records just add reindex: options to any ActiveRecord association.

  Acceptable values are `true, :async`.

  It will hook on:

    1. record update
    2. record destroy
    3. record reindex

  and reindex records reflected in given association.

  Reindexing strategy will depend on specified reindex value.

  ```ruby
  reindex: true # associated in given association records will be reindexed in the same time as
                # current record was updated\destroy\reindexed(Syncronously)
  ```

  ```ruby
  reindex: :async # records will be reindexed (Asyncronously) using ActiveJob as adapter.
  ```

## Examples

```ruby
class Tag < ActiveRecord::Base

  has_many :taggings, reindex: :async
  has_many :super_taggings

end

class Tagging < ActiveRecord::Base

  belongs_to :tag, reindex: true

end

class SuperTagging < ActiveRecord::Base

  belongs_to :tag, reindex: :async

end
```

In this scenario:

If record of Tag model was updated then:
  1. all taggings records associated with given tag will be queued as different jobs for reindexing.
  2. super_taggings will remain as is and will be ignored

If record of Tagging model was updated then:
  1. associated tag will be Syncronously reindexed
  2. all associated taggings(except the one that initiated reindex) will be Asyncronously reindexed

If record of SuperTagging model was updated then:
  1. associated tag will be Asyncronously reindexed
  2. all associated taggings will be Asyncronously reindexed

## TODO

1. Add config for selecting reindex adapter.
2. Add config for selection asyncronous reindex queue.
3. Add config for selecting different job wrappers.
4. Add support for other rails versions on demand(Currently only rails5)
5. Update many-to-x associations records in single job(Configurable)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/Health24/activerecord_reindex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
