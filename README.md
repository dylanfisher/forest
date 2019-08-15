# 🌲 Forest
Forest is a Rails CMS that makes creating and managing websites easy.
It draws inspiration from Wordpress' dashboard and makes it easy to upload images,
manage menus, create users with permissions, etc.

## Generating a new app
```
rails new myapp --database=postgresql
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'forest', git: 'https://github.com/dylanfisher/forest.git'
```

Install gems
```bash
$ bundle
```

Create database and run migrations
```
$ rails db:create
```

Run Forest install generator and follow post-install prompts
```bash
$ rails g forest:install
```

Springify your project, if you're into that sort of thing.
```bash
$ bundle exec spring binstub --all
```

Delete the ApplicationRecord file to inherit from Forest's ApplicationRecord.

Define a `root_path` in your host app's routes file
```ruby
root to: 'home_pages#show'
```

Add the blocks directory to Rails' autoload paths:

```ruby
# application.rb
config.autoload_paths << "#{config.root}/app/models/blocks"
```

You may want to add the following code to make it easy to monkey patch Forest's classes:

```ruby
# application.rb
config.to_prepare do
  # Load application's model / class decorators
  Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
    Rails.configuration.cache_classes ? require(c) : load(c)
  end
end
```

Additional instructions and deployment suggestions are outlined in the [Wiki](https://github.com/dylanfisher/forest/wiki).

For an example of a host app running Forest, view [github.com/dylanfisher/forest_blog](https://github.com/dylanfisher/forest_blog).

## Features
Forest aims to include the following features out of the box.

### Pages
Pages are schedulable and draftable. Each page is composed of a series of blocks that
a user can use to create dynamic page layouts. Additional blocks are easy to develop using regular Ruby
classes and methods. Forest doesn't use any custom DSL.

### Media Browser
An intuitive media browser, similar to Wordpress, is included by default and features multi-file drag and drop upload,
and an easy to use modal interface for selecting associated files.

### Menus
A draggable, nestable interface for managing menus, similar to Wordpress.

### Users
Users and user groups, a permissions system, and secure authentication using Devise.

## Creating additional block types
First, run the block type generator. Make sure to restart your server when generating new blocks.

```
rails generate forest:block TitleAndTextBlock title:string content:text
```

## Custom SimpleForm inputs
A number of custom SimpleForm inputs and components are baked into Forest: https://github.com/dylanfisher/forest/wiki/SimpleForm-inputs-&-components

## Video associations uploaded as Media Items
```ruby
# in your migration
add_reference :video_blocks, :video, foreign_key: { to_table: :media_items }
```

```ruby
# video_block.rb
belongs_to :video, class_name: 'MediaItem'
```

```erb
<%= f.association :media_item, label: 'Video', remote: { path: admin_media_items_path(videos: true) } %>
```

## Custom error pages
Add this line to application.rb to tell your host app to use the router to handle errors.

`config.exceptions_app = self.routes`

Delete the error pages in /public to avoid collision with the custom error pages.

Forest's router will render the appropriate error template via `ErrorsController`. Override the placeholder views to customize the error page.

To test the errors in development, set the following config to false.

```ruby
# development.rb
config.consider_all_requests_local = false
```

## Search
Forest makes it easy to integrate with Elasticsearch. Just include the `Searchable` concern in any ActiveRecord models that you want to be searchable.

Then, override the SearchIndexManager method below to indicate which models should be indexed.

```ruby
SearchIndexManager.class_eval do
  def self.indexed_models
    [Page, BlogPost]
  end
end
```

Index your documents using the tasks in forest_elasticsearch_tasks.rake. To rebuild the search index, you'd run:

`bin/rails forest:elasticsearch:rebuild`

## Primary Dependencies
Forest relies heavily on the following gems, software and frameworks:

- bootstrap
- cocoon
- devise
- has_scope
- jquery
- kaminari
- paperclip
- postgres
- pundit
- redcarpet
- simpleform

## TODO

Better Documentation
- [ ] document how to use `has_many_ordered` and how to make it work in more complex scenarios, e.g. `has_many_ordered :program_artists, through: :program_program_artists, has_many_options: { source: 'artist' }`

Big Picture
- [ ] move admin helper methods to definition in Admin::ForestController to avoid helper methods on the frontend host app
- [ ] change references to model names and other hard coded names to use I18n
- [ ] model resource_description should use I18n
- [ ] add rake task to download database dumps from heroku and store in S3
- [ ] add additional og tags http://ogp.me/
- [ ] add schema.org microdata where appopriate, e.g. for navigation menus, headers, footers
- [ ] is it better to namespace engine?
- [ ] tests

Admin
- [ ] simpleMDE markdown editor has a bug where sometimes the text area gets messed up and needs to have the page resize functions run to work properly again.
- [ ] fix user login page view when signing up for the first time and passwords don't match.
- [ ] nested forms are cumbersome at laptop size. It should be easier to rearrange nested items.
- [ ] add ability to insert nested form items in between other nested items.
- [ ] do something more useful with the admin#show view
- [ ] email confirmations for user related actions
- [ ] versioning option for data associated pages, settings, menus, etc.
- [ ] version diff UI like wordpress?
- [ ] modal to create associated records directly from association page?
- [ ] bulk actions to delete pages (and other records)
- [ ] duplicate records
- [ ] add an option to repeater field to allow adjusting number of fields in each repeated set.
- [ ] remove font-awesome dependency from simplemde markdown editor

Pages
- [ ] proper drafting/publishing permissions for drafted/published pages
- [ ] better page versioning, page history navigation, restore content blocks with page version

Blocks
- [ ] add a duplicate block button to make adding additional blocks of the same type quicker and easier
- [ ] is it possible to add the ability to create blocks within nested forms?
- [ ] minimum and maximum blocks per layout

Media Gallery
- [ ] add drag and drop upload to media item edit view
- [ ] add direct to S3 file upload for large files like video, that otherwise look like they timeout on heroku
- [ ] use mini_magick or similar, more efficient image editor to process paperclip files
- [ ] better media item upload in media_item#edit
- [ ] crop tool and other enhancements
- [ ] configure paperclip to generate optimized images so that google page speed test doesn't complain about the lack of savings.

## Contributing
If you are interested in contributing to this project please [get in touch](mailto:hi@dylanfisher.com).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
