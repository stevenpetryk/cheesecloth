# CheeseCloth

Makes filtering in Rails based on params less of a pain. CheeseCloth provides a helpful, 2-macro DSL
to help you chain filters together that only run if a given param is present.

* [Introduction](#introduction)
* [Installation](#installation)
* [Examples](#examples)
* [Development](#contributing)
* [Contributing](#contributing)
* [License](#contributing)

---

## Justification

**Want to skip the intro? Check out the [examples section](#examples).**

Dealing with filtering based on params in Rails is a pain.

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
good developer, and you extract these filters out into an `EventFilterer` object:

```rb
class EventFilterer
  attr_reader :scope, :user, :params

  def initialize(scope = Event.all, user, params)
    @scope = scope
    @user = user
    @params = params
  end

  def filtered_scope
    if start_date
      @scope = @scope.where("starts_at > ?", start_date)
    end

    if end_date
      @scope = @scope.where("ends_at < ?", end_date)
    end

    if current_user_attending?
      @scope = @scope.where_user_attending(user)
    end

    @scope
  end

  private

  def start_date
    parse_date(params[:start_date])
  end

  def end_date
    parse_date(params[:end_date])
  end

  def current_user_attending?
    parse_boolean(params[:current_user_attending])
  end

  def parse_date(iso_string)
    Time.zone.parse(iso_string || "")
  end

  def parse_boolean(bool_string)
    !["f", "false", "0", ""].includes?(bool_string)
  end
end
```

This is a win, right? Sure! At least, it flies with your boss. But there's so much boilerplate. We
can do better.

```rb
class EventFilterer
  include CheeseCloth

  attr_reader :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  scope -> { Event.all }

  filter :start_date do
    scope.where("starts_at > ?", start_date)
  end

  filter :end_date do
    scope.where("ends_at < ?", end_date)
  end

  filter :current_user_attending? do
    scope.where_user_attending(user)
  end

  private

  def start_date
    parse_date(params[:start_date])
  end

  def end_date
    parse_date(params[:end_date])
  end

  def current_user_attending?
    parse_boolean(params[:current_user_attending])
  end

  def parse_date(iso_string)
    Time.zone.parse(iso_string || "")
  end

  def parse_boolean(bool_string)
    !["f", "false", "0", ""].includes?(bool_string)
  end
end
```

Neat! We could stop here, and we'd be fully utilizing CheeseCloth—but deserializing params is a
solved problem, and you have many options. I like using Virtus to do it, but you can use anything
that makes your params accessible via methods. Let's see what that looks like.

```rb
class EventFilterer
  include CheeseCloth
  include Virtus.model

  attribute :start_date, DateTime
  attribute :end_date, DateTime
  attribute :current_user_attending, Boolean

  def initialize(params, user:)
    @user = user
    super(params) # mass-assign via Virtus
  end

  scope -> { Event.all }

  filter :start_date do
    scope.where("starts_at > ?", start_date)
  end

  filter :end_date do
    scope.where("ends_at < ?", end_date)
  end

  filter :current_user_attending? do
    scope.where_user_attending(user)
  end
end
```

Now we're talkin'. While there's no hard dependency, CheeseCloth works _really_ well when paired
with Virtus. This pattern keeps our controller beautifully concise:

```rb
class EventsController < ApplicationController
  def index
    render json: filterer.filtered_scope
  end

  private

  def filterer
    EventFilterer.new(params[:filter], user: current_user)
  end
end
```

You can check out [more use cases](#examples) below.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cheesecloth"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cheesecloth

## Examples

### Filtering based on a single parameter

```rb
class FooFilterer
  include CheeseCloth

  scope -> { [1, 2, 3] }

  filter :foo do
    # this will only run if self.foo is truthy.
  end

  private

  def foo
    # ...
  end
end
```

### Filtering based on multiple parameters

```rb
class FooFilterer
  include CheeseCloth

  scope -> { [1, 2, 3] }

  filter [:foo, :bar] do
    # this will only run if self.foo && self.bar
  end

  private

  def foo
    # ...
  end

  def bar
    # ...
  end
end
```

## Applying a filter unconditionally

```rb
class FooFilterer
  include CheeseCloth

  scope -> { [1, 2, 3] }

  filter do
    # this will always run
  end
end
```

## Validating params

CheeseCloth doesn't have any mechanism for validation by design. I'd recommend turning your filterer
into an ActiveModel:

```rb
class FooFilterer
  include CheeseCloth
  include ActiveModel::Model

  # ...

  validates :foo, presence: true
end

class FooController < ActionController::Base
  def index
    if filterer.valid?
      render json: filterer.filtered_scope
    else
      render json: filterer.errors
    end
  end

  private

  def filterer
    FooFilterer.new(...)
  end
end
```

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run
the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new
version, update the version number in `version.rb`, and then run `bundle exec rake release`, which
will create a git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork this repo
2. Add your feature in a branch
3. Open a pull request

Before making a commit, please run `rake spec` and `rubocop` to ensure it will pass CI.

Please write [good commit messages](https://robots.thoughtbot.com/5-useful-tips-for-a-better-commit-message),
be polite, and be open to discussing ways to improve on the code you've contributed.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
