# 🌲 Forest
Forest is a Rails 5 CMS that provides an opinionated starting point when creating new websites.
Much inspiration was drawn from Wordpress' dashboard. The Forest dashboard uses Bootstrap and very little
additional CSS to create an easily customizable interface.

## Features
Forest aims to include the following features out of the box.

### Pages
Pages are versionable, schedulable and draftable. Each page is composed of a series of page blocks that
a user can use to create dynamic page layouts. Additional blocks are easy to develop using regular Ruby
classes and methods. Forest doesn't use any custom DSL.

### Media Browser
An advanced media browser, similar to Wordpress, is included by default and features multi-file drag and drop upload,
and an easy to use modal interface for selecting associated files.

### Menus
An easy to use draggable, nestable interface for managing menus, similar to Wordpress.

### Users
Users and user groups, a permissions system, and secure authentication.

## Usage
Forest runs as an engine. To get started using this gem, create a new rails app and add the forest gem to your gemfile.

Mount forest in your routes.rb file

```
mount Forest::Engine, at: '/'
```

Install Forest's migrations

```
rails forest:install:migrations
```

For an example of a host app running Forest, view [github.com/dylanfisher/forest_blog](https://github.com/dylanfisher/forest_blog).

## Primary Dependencies
Forest relies heavily on the following gems, software and frameworks:

- devise
- pundit
- postgres
- friendly_id
- has_scope
- kaminari
- paperclip
- cocoon
- redcarpet
- simpleform
- bootstrap
- jquery

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'forest', git: 'https://github.com/dylanfisher/forest.git'
```

And then execute:
```bash
$ bundle
```

## TODO

- [ ] tests
- [ ] page status for scheduled, pending and hidden states
- [ ] data associated pages that support blocks
- [ ] better page versioning, page history navigation, restore content blocks with page version
- [ ] additional default content blocks, mainly image and/or gallery, maybe video and/or oEmbed
- [ ] solution for color picker, date picker, map picker, etc. similar to ACF
- [ ] purge cache button
- [ ] add ability to remove media item (e.g. remove feature media item from page)
- [ ] better media item upload in media_item#edit
- [ ] reset password and/or change password when editing user profile
- [ ] email confirmations for user related actions
- [ ] oauth/omniauth?
- [ ] csv import/export
- [ ] s3 storage for paperclip
- [ ] remove bootstrap as frontend dependency (admin navbar is only place this is currently shared)
- [ ] frontend search design
- [ ] remove font-awesome dependency from simplemde markdown editor
- [x] better settings UI, ability to set multiple data types, e.g. boolean, or association

## Contributing
If you are interested in contributing to this project please [get in touch](mailto:hi@dylanfisher.com).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
