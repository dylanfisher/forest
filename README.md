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

Delete the ApplicationRecord file to inherit from Forest's ApplicationRecord.

Define a `root_path` in your host app's routes file
```ruby
root to: 'pages#show' # or whatever makes sense for your home page controller
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

## Creating additional models backed by a CMS scaffold

```
rails generate forest:scaffold Project title:string media_item:references description:text
```

Optional arguments:

`--skip_public` Don't create public controller actions and views

`--skip_blockable` Don't add blockable associations

`--skip_statusable` Don't add a status column to the model

`--skip_sluggable` Don't assume this model needs a slug

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

## Customize Forest Options

A number of configuration options, such as image derivative options, are set in `lib/forest.rb` and can be customized in an initializer in your host app:

```ruby
# Forest.setup do |config|
#   config.image_derivative_large_options[:resize][:width] = 3000
#   config.image_derivative_large_options[:resize][:height] = 3000
#   config.image_derivative_large_options[:jpeg][:quality] = 90
# end
```

## Removing Block Kinds

1. Delete all files related to the block kind (`_show.html.erb`, `edit.html.erb`, etc.).
1. Create a new migration to destroy existing database entries related to the block:
    ```ruby
      def up
        BlockSlot.where(block_type: 'ImageBlock').delete_all
        BlockKind.where(name: 'ImageBlock').delete_all

        remove_foreign_key(:image_blocks, :media_items) if foreign_key_exists?(:image_blocks, :media_items)
        drop_table :image_blocks, if_exists: true
      end
    ```

## Primary Dependencies
Forest relies heavily on the following gems, software and frameworks:

- bootstrap
- cocoon
- devise
- has_scope
- jquery
- pagy
- postgres
- pundit
- redcarpet
- shrine
- simpleform

## TODO

### On Demand Video Transcoder

- Upload video to media library
- Use `Aws::Lambda::Client` to invoke lambda function
  - Pass arguments to lambda function defining `MediaItem` bucket path
  - Lambda function invokes `MediaConvert`
    - In `MediaConvert` callback, send webhook notification to Forest
- Forest recieves webhook notification from `MediaConvert`
  - Webhook supplies `MediaItem` ID and metadata
  - Update `MediaItem` with new video info

Version 2
- [ ] Update settings to support an optional default fallback value for situations where a client may forget to enter a value.
- [ ] Update Pundit::NotAuthorizedError on hidden records to return 404, not 500
- [ ] Fix common errors in URL, e.g. `app/web.1: [a5d5d477-3e7b-411f-85d6-414af80850f2] ActionView::Template::Error (unexpected ''' after '[:equal, "'/page/some-page/'"]'):`
- [ ] Remove hidden `block_layout`, `block_record_type`, `block_kind_id` fields from `block_slot_fields` and instead apply these values in the controller for better security.
- [ ] Add pundit policy scoped to admin namespace, e.g. `authorize([:admin, Post])` https://github.com/varvet/pundit#policy-namespacing
- [ ] Replace authorize index actions with `policy_scope` and make sure policy scope is set up properly
- [ ] Add ability to toggle each individual blocks hidden status
- [ ] Disable choosing a non-image file in the image association
- [ ] Add an easier to use API for creating blocks and associating them to records programmatically
- [ ] Update shrine file content disposition for non-images so that files have a more accurate file name
- [ ] Add Shrine keep_files plugin to prevent deletion of files except in production environment https://shrinerb.com/docs/plugins/keep_files
- [ ] move admin helper methods to definition in Admin::ForestController to avoid helper methods on the frontend host app
- [ ] Update media library drag and drop to use smaller image thumbnail before image is done processing
- [ ] Update scaffold generator to work with namespaced models
- [ ] Replace and/or document suckerpunch background job with sidekiq or similar more resilient solution
- [ ] Show instances of block kinds in the /admin/block-kinds interface
- [ ] Allow configuration of Shrine media upload to allow local file storage
- [ ] Better media item input (allow editing caption in place, show point of interest, etc.)
- [ ] Don't delete media items from S3 storage in dev environment, better Shrine configuration for accidentally deleting files from S3
- [ ] Update site title and description for meta tags
- [ ] Add ability to collapse blocks, and (optionally) allow setting default collapse state
- [ ] Add a refresh button to media item modal to refresh with newly added images
- [ ] Add media item preview icons for PDF/Video and other files. Reference Uppy's pdf icon preview for inspiration
- [ ] Media library needs multi-image delete functionality
- [ ] Can we add indexes to media item attachment_data jsonb column, e.g. to index if a derivative is present?
- [ ] Add ability to redirect to a page association, not just a string field
- [ ] Allow menu items to link to reference a page ID in addition to a page path
- [ ] scope simpleform configuration in engine so that global config doesn't interfere with host app
- [ ] change references to model names and other hard coded names to use I18n
- [ ] model resource_description should use I18n
- [ ] better pattern for defining custom status message via I18n
- [ ] add method to duplicate records
- [ ] versioning option for data associated pages, settings, menus, etc. Version diffing ala wordpress.
- [ ] better page versioning, page history navigation, restore content blocks with page version
- [ ] email confirmations for user related actions
- [ ] more robust and flexible permissions system via pundit
- [ ] replace glyphicon with bootstrap 4 icons
- [ ] tests
- [ ] streamlined javascript event triggers namespaced to forest, e.g. `forest:block-slot-after-insert`
- [ ] potentially refactor how settings are stored, how a setting's value type is inferred, how they are imported, and potentially add a reference to other models so that a model's settings can be displayed when editing a record.
- [ ] add description to settings admin index view
- [ ] add an easy way to add various metadata and settings to a page without having to add new columns to the `Page` record

Blocks
- [ ] refactor block partial to use helper for possible performance gains
- [ ] add a duplicate block button to make adding additional blocks of the same type quicker and easier
- [ ] add ability to drag certain content types, e.g. media items, between blocks
- [ ] minimum and maximum blocks per layout

Media Gallery
- [ ] search and replace all legacy references of attachment with new attachment_url method e.g. search for `.attachment.`
- [ ] add drag and drop upload to media item edit view
- [ ] add direct to S3 file upload for large files like video, that otherwise look like they timeout on heroku
- [ ] ability to categorize media items on the backend, e.g. different directories of images
- [ ] document the new requirements for using the media library, e.g. create the CloudFormation stack, add a background job library to host app's gemfile

## Contributing
If you are interested in contributing to this project please [get in touch](mailto:hi@dylanfisher.com).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
