### 🚧 Under Construction 🚧

# 🌲 Forest
Forest is a Rails 5 CMS that makes creating and managing websites easy.
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

## Usage
Forest runs as an engine. To get started using this gem, create a new rails app and add the forest gem to your gemfile.

Mount forest in your routes.rb file

```
mount Forest::Engine, at: '/'
```

Install Forest's migrations

```bash
bin/rails railties:install:migrations
```

Delete `layouts/application.html.erb` to use Forest's layout.

Update your ApplicationRecord to inherit from `Forest::ApplicationRecord`

```ruby
class ApplicationRecord < Forest::ApplicationRecord
end
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

Configure bootsnap if necessary by adding the following right underneath `require 'bundler/setup'`:

```ruby
# boot.rb
require 'bootsnap/setup'
```

For an example of a host app running Forest, view [github.com/dylanfisher/forest_blog](https://github.com/dylanfisher/forest_blog).

## Features
Forest aims to include the following features out of the box.

### Pages
Pages are versionable (coming soon), schedulable and draftable. Each page is composed of a series of blocks that
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
These custom SimpleForm inputs are available in your form builders by setting an `as` option.

#### datepicker_input.rb
Render a date or datetime input using a jQuery UI datepicker.

`<%= f.input :date, as: :datepicker %>`

#### gallery_input.rb
A sortable gallery of Media Items.

`<%= f.association :images, as: :gallery, sortable: true %>`

#### image_input.rb
A single image association.

`<%= f.association :featured_image, as: :image %>`

#### repeater_input.rb
Create a repeatable set of key, value pairs. These are saved as a serialized array directly on the model.
Useful when you don't need a full has_and_belongs_to_many association.

Add a text column where you want to store the repeatable data, for example a column named `additional_metadata`

Then, in your model:

`has_repeatable :additional_metadata`

And in your form:

`<%= f.input :metadata, as: :repeater %>`

#### collage_input.rb
Create a collage of Media Items that you can drag to rearrange on a resizable canvas.

Generate the block:

`rails g forest:block CollageBlock collage_height_ratio:decimal`

Generate the associated collage items:

`rails g model CollageBlockItem media_item:references collage_block:references collage_position_left:decimal collage_position_top:decimal collage_item_width:decimal collage_item_height:decimal collage_z_index:integer`

```ruby
# collage_block.rb
has_many :collage_block_items, dependent: :destroy
has_many :media_items, through: :collage_block_items

accepts_nested_attributes_for :collage_block_items, allow_destroy: true, reject_if: :all_blank
```

```erb
<%# /app/views/blocks/collage_block/_edit.html.erb %>
<%= f.association :collage_block_items, as: :collage %>
```

If you need to add additional fields to the collage items, you can insert them into the edit view by creating a partial at the following location:

`/app/views/blocks/collage_block/_collage_fields.html.erb`

## Custom SimpleForm components
These custom SimpleForm components are available in your form builders by setting the component option to true.

#### markdown.rb
Render a text field with a WYSIWYG markdown editor.

`<%= f.input :description, markdown: true %>`

#### remote.rb
Render an association that may have many records using an ajax select2 input.

`<%= f.association :page, remote: true %>`

Explicitly set the ajax path:

`<%= f.association :project, remote: { path: admin_projects_path(active: true) } %>`

#### sortable.rb
Create sortable select2 inputs by using a custom ActiveRecord class method:

```
# project_block.rb

has_many_ordered :projects, through: :project_block_projects
```

```
# project_block/_edit.html.erb

<%= f.association :projects, sortable: true, remote: true %>
```

## Video associations uploaded as Media Items
```
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

Index your documents using the tasks in forest_elasticsearch_tasks.rake. To rebuild the search index, you'd run:

`rake forest:elasticsearch rebuild`

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

Big Picture
- [ ] decouple admin js/css with public js/css
- [ ] add a documentation page directly within the forest cms with FAQ and basic overview of how to use the cms.
- [ ] add additional og tags http://ogp.me/
- [ ] add schema.org microdata where appopriate, e.g. for navigation menus, headers, footers
- [ ] is it better to namespace engine?
- [ ] document custom simple form components and inputs
- [ ] squash migrations once final db structure is settled upon
- [ ] tests
- [x] 404 page, error pages. Document how to customize these.
- [x] rip out paper_trail gem in favor of our own solution for versioning
- [x] add optional: true to optional belongs_to associations http://blog.bigbinary.com/2016/02/15/rails-5-makes-belong-to-association-required-by-default.html
- [x] better naming conventions when it comes to blocks, block_record, and block_slots
- [x] add has_many ordered simpleform input and select2 option
- [x] remove any gem dependencies not totally necessary?

Admin

- [ ] nested forms are cumbersome at laptop size. It should be easier to rearrange nested items.
- [ ] add ability to insert nested form items in between other nested items.
- [ ] do something more useful with the admin#show view
- [ ] more robust filter pattern for index views, and ability to select by multiple filters + search,
      and retain these filters when navigating between records
- [ ] email confirmations for user related actions
- [ ] add migrations to host app without running install:migrations command
- [ ] versioning option for data associated pages, settings, menus, etc.
- [ ] version diff UI like wordpress?
- [ ] modal to create associated records directly from association page?
- [ ] bulk actions to delete pages (and other records)
- [ ] duplicate records
- [ ] add an option to repeater field to allow adjusting number of fields in each repeated set.
- [ ] remove font-awesome dependency from simplemde markdown editor
- [x] reset password and/or change password when editing user profile
- [x] intuitive select2 association UI
- [x] sortable select2 items
- [x] add select2 with remote ajax selects, automatically infer path to avoid manual setup for each association input
- [x] remove bootstrap as frontend dependency (admin navbar is only place this is currently shared)
- [x] purge cache button
- [x] s3 storage for paperclip, assets, heroku support, etc.
- [x] bulk csv import

Generators

- [ ] initial app generator `rails g forest:install` and move migrations that seed initial data into the generator
- [ ] add more notes to post-install message about what to do for first time installs. e.g. inheriting from Forest::ApplicationRecord, if this is necessary.
- [ ] add ability to skip block_record creation when creating new scaffold that doesn't need to support blocks
- [x] generate a simple json.jbuilder for admin indexes by default
- [x] scaffold generator
- [x] block type generator

Pages

- [ ] if you modify form data and navigate away from the page, prompt user for confirmation
      https://github.com/turbolinks/turbolinks-classic/issues/249#issuecomment-302279482
- [ ] proper drafting/publishing permissions for drafted/published pages
- [ ] page groups / page heirarchy
- [ ] show page hierarchy in select2 selection?
- [ ] page status for scheduled, pending and hidden states
- [ ] better page versioning, page history navigation, restore content blocks with page version
- [x] data associated pages that support blocks

Blocks

- [ ] is it possible to add the ability to create blocks within nested forms?
- [ ] additional default content blocks, mainly image and/or gallery, maybe video and/or oEmbed
- [ ] minimum and maximum blocks per layout
- [ ] solution for color picker, date picker, map picker, etc. similar to ACF
- [x] remove all blocks from forest and instead output a command to generate your first block after the install generator runs
- [x] more performant record saving when parsing block attributes
- [x] validate block attributes before saving page

Media Gallery

- [ ] add ability to specify image format, perhaps with a just-in-time file processing like this example http://www.ryanalynporter.com/2012/06/07/resizing-thumbnails-on-demand-with-paperclip-and-rails/
- [ ] when uploading video via drag and drop, the preview icon doesn't update properly after upload completes
- [ ] add direct to S3 file upload for large files like video, that otherwise look like they timeout on heroku
- [ ] in the fileUpload progress bar, once the files have been uploaded, change the progress bar to indicate that the server is processing the images. Right now it looks like it just hangs on a 100% green bar.
- [ ] use mini_magick or similar, more efficient image editor to process paperclip files
- [ ] fix slug generation to support uploading images/files with the same name
- [ ] better media item upload in media_item#edit
- [ ] ability to add new media items through modals (e.g. featured in on pages)
- [ ] ability to upload other file types, not just images (pdf, video, audio)
- [ ] ability to associate multiple media items at once, e.g. for a carousel
- [ ] crop tool and other enhancements
- [ ] configure paperclip to generate optimized images so that google page speed test doesn't complain about the lack of savings.
- [x] store image dimensions and metadata in attachment https://github.com/thoughtbot/paperclip/wiki/Extracting-image-dimensions
- [x] add ability to remove media item (e.g. remove feature media item from page)

Menus

- [ ] refactor menus to use nested rails forms rather than serialized json
- [ ] create pattern for linking to other record types in navigation menus
- [x] ability to remove menu items

Search

- [ ] frontend search design

JavaScript
- [x] better namespacing of all custom events. e.g. they should be `forest:my-custom-event`

Sass
- [ ] potentially speed up sass compilation by following pattern like this? http://blog.teamtreehouse.com/tale-front-end-sanity-beware-sass-import

Settings

- [ ] when updating featured image setting the home page cache didn't seem to get busted. Need to confirm this.
- [ ] when a setting is references in production.rb precompiling assets fails
- [ ] add documentation for how settings should be added. Right now they must be initialized from the i18n en:forest:settings yaml file.
- [x] featured image setting sets the og:image to :small size. It should use large size.
- [x] better settings UI, ability to set multiple data types, e.g. boolean, or association

## Contributing
If you are interested in contributing to this project please [get in touch](mailto:hi@dylanfisher.com).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
