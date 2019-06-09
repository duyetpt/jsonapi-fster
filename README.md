# Jsonapi::Fster
Short description and motivation.

## Usage
1. In model
```ruby
include include Jsonapi::Fster::ActAsFilter
```
2. Call filter
```ruby
Model.where_jsonapi_filter params
```

## Feature
* [x] Support filter as filters params follow json-api format.
* [x] Support left outer joins.
* [x] Support sorting.
* [x] Support all deep levels.
* [ ] Support paging.
* [ ] Support filter by range
* [ ] Support datetime format

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'jsonapi-fster'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install jsonapi-fster
```

Example
1. Simple filter by column
```ruby
    Session.where_jsonapi_filter name: 'hello'
```

2. With relationships
```ruby
    Course.has_many :session
    Session.belongs_to :course

    # Will find all sessions has course with name is `hello`.
    Session.where_jsonapi_filter 'course.name': 'hello'

    # Will find all sessions of course 1 and course 2
    Session.where_jsonapi_filter course: '1,2'

    # Get all courses of sessions 1,2,3
    Course.where_jsonapi_filter sessions: '1,2,3'

    # User left_outer_joins
    Course.where_jsonapi_filter sessions: '1,2,3', 'left_outer_joins'
```

3. More complex filter
```ruby
    # Get all sessioins in categories G, Y and S.
    # Categories and courses relationship is has_many or has_many through one.
    Session.where_jsonapi_filter 'course.categories.code': 'G,Y,S'

    # User left outer joins
    Session.where_jsonapi_filter 'course.categories.code': 'G,Y,S', 'left_outer_joins'

    # Get all sessions of studio with name is Thanos.
    Session.where_jsonapi_filter 'course.studio.name': 'Thanos'
```

4. Sorting
```ruby
    # acs order
    Session.jsonapi_order('id')

    # desc order
    Session.jsonapi_order('-id')

    # multiple order
    Session.jsonapi_order('-id,name,-code')
```

## Contributing
### How to test
1. Run `cd test/dump`.
2. Setup database `rails db:migrate`.
3. In root folder of project run, run test.
```cmd
bin/test test/jsonapi/act_as_filter_test.rb
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
