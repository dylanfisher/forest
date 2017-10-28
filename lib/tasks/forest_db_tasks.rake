namespace :forest do
  desc "Download and replace this database with a current capture from heroku."
  task 'db:capture' => :environment do
    db = Rails.application.config.database_configuration[Rails.env]
    user = db['username']
    database = db['database']
    puts "[Forest] This command captures a snapshot of the Heroku database, downloads it, drops the local database and recreates if from the Heroku snapshot."
    puts "[Forest] Please run:"
    puts "heroku pg:backups:capture && heroku pg:backups:download && bin/rails db:drop && bin/rails db:create && pg_restore --verbose --clean --no-acl --no-owner -h localhost #{if user then "-U #{user}" end} -d #{database} latest.dump; rm latest.dump"
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
      puts 'bin/rails db:drop && bin/rails db:create'
      puts "pg_restore --verbose --host localhost #{if user then "-U #{user}" end} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
    end
  end

  private

    def with_config
      yield Rails.application.class.parent_name.underscore,
        ActiveRecord::Base.connection_config[:database],
        ActiveRecord::Base.connection_config[:username]
    end
end
