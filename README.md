# Jsonapi::Fster
Support filter, paging, order if params follow jsonapi standard.

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
* [x] Support paging by will_page.
* [x] Support filter by range for integer, datetime.
* [x] Support datetime format.
* [x] Support like query.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'jsonapi-fster'
```

And then execute:
```bash
$ bundle install
```

Or install as:
```bash
$ gem install jsonapi-fster
```

Example
1. Include fster into model
```ruby
    Session.include Jsonapi::Fster::ActAsFster
```

2. Simple filter by column
```ruby
    Session.where_jsonapi name: 'hello'
```

3. With relationships
```ruby
    Course.has_many :session
    Session.belongs_to :course

    # Will find all sessions has course with name is `hello`.
    Session.where_jsonapi 'course.name': 'hello'

    # Will find all sessions of course 1 and course 2 and paging using will_page
    Session.where_jsonapi course: '1,2', page: 1, per_page: 10

    # Get all courses of sessions 1,2,3, sort asc by name
    Course.where_jsonapi sessions: '1,2,3', sort: 'name'

    # User left_outer_joins
    Course.where_jsonapi sessions: '1,2,3', 'left_outer_joins'
```

4. More complex filter
```ruby
    # Get all sessioins in categories G, Y and S.
    # Categories and courses relationship is has_many or has_many through one.
    Session.where_jsonapi 'course.categories.code': 'G,Y,S', sort: 'start_at', page: 1, per_page: 20

    # User left outer joins
    Session.where_jsonapi 'course.categories.code': 'G,Y,S', 'left_outer_joins'

    # Get all sessions of studio with name is Thanos.
    Session.where_jsonapi 'course.studio.name': 'Thanos'
```

5. Sorting
```ruby
    # acs order
    Session.jsonapi_order('id')

    # desc order
    Session.jsonapi_order('-id')

    # multiple order
    Session.jsonapi_order('-id,name,-code')
```

6. Like query
```ruby
    Course.where_jsonapi 'name.lk': '%gym'
    Course.where_jsonapi 'name.lk': '%yoga%'
```

## Contributing
### How to test
1. Run `cd test/dump`.
2. Setup database `rails db:migrate`.
3. In root folder of project run, run test.
```cmd
bin/test test/jsonapi/*
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
