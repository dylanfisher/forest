require 'open-uri'

namespace :forest do
  desc "Download and replace this database with a current capture from heroku."
  task 'db:capture' => :environment do
    db = Rails.application.config.database_configuration[Rails.env]
    user = db['username']
    database = db['database']
    puts "[Forest] This command captures a snapshot of the Heroku database, downloads it, drops the local database and recreates it from the Heroku snapshot."
    puts "[Forest] Please run:"
    puts "heroku pg:backups:capture && heroku pg:backups:download && bin/rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1 && bin/rails db:create && pg_restore --verbose --clean --no-acl --no-owner -h localhost #{if user then "-U #{user}" end} -d #{database} latest.dump; rm latest.dump"
  end

  # https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90
  desc "Dumps the database to db/APP_NAME.dump"
  task 'db:dump' => :environment do
    with_config do |app, db, user|
      puts "[Forest] This task dumps the database to #{Rails.root}/db/#{app}.dump"
      puts "[Forest] Please run:"
      puts "pg_dump --host localhost #{if user then "-U #{user}" end} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
    end
  end

  # https://gist.github.com/hopsoft/56ba6f55fe48ad7f8b90
  desc "Restores the database dump at db/APP_NAME.dump"
  task 'db:restore' => :environment do
    with_config do |app, db, user|
      puts "[Forest] This task restores the database from #{Rails.root}/db/#{app}.dump"
      puts "[Forest] Please run:"
      puts 'bin/rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1 && bin/rails db:create'
      puts "pg_restore --verbose --host localhost #{if user then "-U #{user}" end} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
  end

  desc "Import the database to Heroku."
  task 'db:import_to_heroku' => :environment do
    with_config do |app, db, user|
      check_for_s3_env_variables!

      timestamp = Time.now.to_i

      object_key = "forest/forest_db_dumps/#{app}_#{timestamp}.dump"
      if s3_bucket.object(object_key).upload_file("#{Rails.root}/db/#{app}.dump")
        s3.client.put_object_acl({
          acl: 'public-read',
          bucket: s3_bucket.name,
          key: object_key
        })

        puts "[Forest] Careful! You just uploaded a publicly accessible db dump to the #{s3_bucket.name} bucket."
        puts "[Forest] To import that db dump to Heroku, please run:"

        puts "heroku pg:backups:restore 'https://s3.amazonaws.com/#{s3_bucket_name}/#{object_key}' DATABASE_URL"
        puts "\n"
        puts "[Forest] ** After importing to Heroku, run this command to delete the public db dump from Amazon S3. Don't leave the db dump publicly accessible! **"
        puts "bin/rails forest:db:destroy_s3_dump object_key=#{object_key}"
      else
        puts "[Forest] Error: unable to upload object to S3."
      end
    end
  end

  desc "Destroy a database dump from Amazon S3."
  task 'db:destroy_s3_dump' => :environment do
    check_for_s3_env_variables!

    if s3_bucket.object(ENV['object_key']).delete
      puts "[Forest] #{ENV['object_key']} destroyed"
      remaining_objects = s3_bucket.objects(prefix: 'forest/forest_db_dumps/').collect(&:key).reject { |k| k == 'forest/forest_db_dumps/' }
      if remaining_objects.present?
        puts "[Forest] Warning: There are still files in the forest/forest_db_dumps directory (this directory should be empty!). Please delete these publicly accessible files."
        puts "[Forest] Run the following commands to delete the objects:"
        remaining_objects.each do |object_key|
          puts "bin/rails forest:db:destroy_s3_dump object_key=#{object_key}"
        end
      end
    else
      puts "[Forest] Error: unable to destroy #{ENV['object_key']}. Log in to Amazon S3 and destroy the object manually."
    end
  end

  desc "Upload the latest Heroku database to S3 for archival purposes. This assumes you have already enabled daily pg backups on Heroku."
  task 'db:archive_to_s3' => :environment do
    # TODO: This won't work as is because the heroku CLI isn't available by default on
    # heroku. It may be better to use https://github.com/kbaum/heroku-database-backups.
    # TODO: add configuration that allows setting a maximum number of database backups.
    # The price class could also be adjusted, for example setting S3 One Zone-IA Storage
    # for very old files to save $$.

    check_for_s3_env_variables!

    url = `heroku pg:backups public-url`
    url.sub!(/\n$/, '')

    db_uri = URI.parse(url)

    file_name = db_uri.path.split('/').reject(&:blank?).join('_')
    object_key = "forest/forest_db_archives/#{database_name}/#{file_name}.gz"
    object = s3_bucket.object(object_key)

    abort("[Forest] Database already exists on S3, aborting #{s3_bucket_name} #{object_key}") if object.exists?

    file = Tempfile.new(["#{file_name}", '.sql'])

    puts "[Forest] Downloading database from Heroku"
    open(url) do |f|
      IO.copy_stream(f, file)
    end

    puts "[Forest] Compressing database file"

    zipped_file = Tempfile.new(["#{file_name}", '.gz'])

    Zlib::GzipWriter.open(zipped_file) do |gz|
      gz.mtime = File.mtime(file)
      gz.orig_name = "#{file_name}.sql"
      File.open(file) do |file|
        while chunk = file.read(16*1024) do
          gz.write(chunk)
        end
      end
    end

    puts "[Forest] Uploading database file to S3"
    if object.upload_file(zipped_file)
      s3.client.put_object_acl({
        acl: 'private',
        bucket: s3_bucket.name,
        key: object_key
      })
    else
      puts "[Forest] Error: unable to upload object to S3."
    end

    file.delete
    zipped_file.delete
  end

  private

    def with_config
      yield Rails.application.class.parent_name.underscore,
        database_name,
        ActiveRecord::Base.connection_config[:username]
    end

    def s3
      @s3 ||= Aws::S3::Resource.new(region: aws_region)
    end

    def s3_bucket
      @s3_bucket ||= s3.bucket(s3_bucket_name)
    end

    def check_for_s3_env_variables!
      abort('[Forest] Error: Please specify an AWS_REGION environment variable') if aws_region.blank?
      abort('[Forest] Error: Please specify an S3_BUCKET_NAME environment variable') if s3_bucket_name.blank?
    end

    def aws_region
      @aws_region ||= ENV['AWS_REGION'].presence || Rails.application.credentials&.dig(:aws, :aws_region)
    end

    def s3_bucket_name
      @s3_bucket_name ||= ENV['S3_BUCKET_NAME'].presence || Rails.application.credentials&.dig(:aws, :s3_bucket_name)
    end

    def database_name
      @database_name ||= ActiveRecord::Base.connection_config[:database]
    end
end
