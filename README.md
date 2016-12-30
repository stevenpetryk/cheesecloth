# CheeseCloth

Makes filtering in Rails based on params less of a pain. CheeseCloth provides a transparent, tiny
DSL to help you chain filters together that only run if a given param is present.

* [Introduction](#introduction)
* [Installation](#installation)
* [Examples](#examples)
  * [Filtering based on a single parameter](#filtering-based-on-a-single-parameter)
  * [Filtering based on multiple parameters](#filtering-based-on-multiple-parameters)
  * [Applying a filter unconditionally](#applying-a-filter-unconditionally)
  * [Overriding the starting scope](#overriding-the-starting-scope)
  * [Validating parameters](#validating-parameters)
  * [Real world example (Virtus + ActiveModel)](#real-world-example-virtus--activemodel)
* [Development](#contributing)
* [Contributing](#contributing)
* [License](#contributing)

---

## Introduction

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

  def initialize(params, user:, scope: Event.all)
    @params = params
    @user = user
    @scope = scope
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

  def initialize(params, user:)
    @params = params
    @user = user
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
    super(params) # mass-assignment via Virtus
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
with Virtus. Here's our controller, by the way:

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

Nice and simple. You can check out [more use cases](#examples) below.

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

  attr_reader :foo

  def initialize(foo:)
    @foo = foo
  end

  scope -> { [1, 2, 3] }

  filter :foo do
    # this will only run if self.foo is truthy.
    scope.reverse
  end
end

FooFilterer.new(foo: true).filtered_scope #=> [3, 2, 1]
FooFilterer.new(foo: false).filtered_scope #=> [1, 2, 3]
```

### Filtering based on multiple parameters

```rb
class FooFilterer
  include CheeseCloth

  attr_reader :foo, :bar

  def initialize(foo:, bar:)
    @foo, @bar = foo, bar
  end

  scope -> { [1, 2, 3] }

  filter [:foo, :bar] do
    # this will only run if self.foo && self.bar
    scope - [2]
  end
end

FooFilterer.new(foo: true, bar: true).filtered_scope #=> [1, 3]
FooFilterer.new(foo: true, bar: false).filtered_scope #=> [1, 2, 3]
```

### Applying a filter unconditionally

```rb
class FooFilterer
  include CheeseCloth

  scope -> { [1, 2, 3] }

  filter do
    scope + [4, 5, 6]
    # this will always run
  end
end

FooFilterer.new.filtered_scope #=> [1, 2, 3, 4, 5, 6]
```

### Overriding the starting scope

If you need to, you can override the starting scope at "runtime" (a.k.a, right before the filters
are ran). `#filtered_scope` takes an optional `scope` keyword argument.

```rb
class FooFilterer
  include CheeseCloth

  scope -> { [1, 2, 3] }

  filter do
    scope + [4, 5, 6]
    # this will always run
  end
end

FooFilterer.new.filtered_scope(scope: [1]) #=> [1, 4, 5, 6]
```

### Validating parameters

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

### Real-world example (Virtus + ActiveModel)

The previous examples could have, of course, been simplified with the use of Virtus to handle
mass assignment and deserialization, and using ActiveModel's validations. Here's a real-world
scenario, with a corresponding controller action. Imagine our endpoint had the following criteria:

* Venue type must be specified.
* Start date and end date will either both be specified, or neither will be. If only one is
specified, don't filter based on date.

```rb
class EventsFilterer
  include CheeseCloth
  include Virtus.model
  include ActiveModel::Model

  attribute :venue_type, String
  attribute :start_date, DateTime
  attribute :end_date, DateTime

  validates :venue_type, presence: true

  scope -> { Event.all }

  filter :venue_type do
    scope.at_venue_type(venue_type)
  end

  filter [:start_date, :end_date] do
    scope.within_dates(start_date, end_date)
  end
end

class EventsController < ApplicationController
  def index
    if filterer.valid?
      # Note that we limit the scope to only the current user's events. Nifty!
      render json: filterer.filtered_scope(scope: current_user.events)
    else
      render json: filterer
    end
  end

  private

  def filterer
    EventsFilterer.new(params[:filter])
  end
end

class Event < ApplicationRecord
  scope :at_venue_type, ->(type) { where(venue_type: type) }
  scope :within_dates, ->(start_date, end_date) do
    where("starts_at BETWEEN ? and ?", start_date, end_date)
  end

  # ...
end
```

## Development

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
