# CheeseCloth

Dealing with filtering based on params in Rails APIs is a pain.

Let's say the boss tells you that you need to implement an endpoint for fetching Events. This
endpoint needs to allow you to filter by a (possibly one-sided) date range, and also optionally only
include events that the current user is attending.

```
GET /api/events
      ?filter[start_date]=2016-10-1
      &filter[end_date]=2016-11-1
      &filter[current_user_attending]=true
```

Your controller action quickly becomes a nightmare. But wait—you're a
good developer, and you extract these filters out into a `EventFilterer` object:

```rb
class EventFilterer
  attr_reader :scope, :user, :params

  def initialize(scope = Event.all, user, params)
    @scope = scope
    @user = user
    @params = params
  end

  def filtered_collection
    if parse_date(params[:start_date])
      @scope = @scope.where("starts_at > ?", params[:start_date])
    end

    if parse_date(params[:start_date])
      @scope = @scope.where("ends_at < ?", params[:start_date])
    end

    if parse_boolean[:current_user_attending]
      @scope = @scope.where_user_attending(user)
    end

    @scope
  end

  private

  def parse_date(iso_string)
    Time.zone.parse(iso_string || "")
  end

  def parse_boolean(bool_string)
    !["f", "false", "0", ""].includes?(bool_string)
  end
end
```

This is a win, right? Wrong! At least, it flies with your boss—until she asks you to make these
params required, validate their format, and provide nice error messages whenever validation fails.
Better yet, she asks if you can add similar filters to another endpoint, meaning you have to DRY
up this solution.

Yikes. We can do better.

```rb
class EventFilterer
  include CheeseCloth

  scope -> { Event.all }

  param :start_date, :date, required: true
  param :end_date, :date, required: true
  param :current_user_attending, :boolean, required: true

  filter :start_date do
    scope.where("starts_at > ?", start_date)
  end

  filter :end_date do
    scope.where("ends_at < ?", end_date)
  end

  filter :current_user_attending do
    scope.where_user_attending(user)
  end

  def start_date_before_end_date
    throw "start date must be before end date" unless start_date <= end_date
  end
end
```

Using this in our controller is incredibly simple.

```rb
class EventsController < ApplicationController
  def index
    if filterer.valid?
      render json: filterer.filtered_collection
    else
      render json: { errors: filterer.errors }, status: 422
    end
  end

  private

  def filterer
    EventFilterer.new(params[:filter], user: current_user)
  end
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cheese_cloth"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cheesecloth

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork this repo
2. Add your feature in a branch
3. Open a pull request

Before making a commit, please run `rake spec` and `rubocop` to ensure it will pass CI.

Please write [good commit messages](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message),
be polite, and be open to discussing ways to improve on the code you've contributed.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
