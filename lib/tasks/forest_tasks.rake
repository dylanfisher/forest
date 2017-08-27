desc "Download and replace this database with a current capture from heroku."
namespace :forest do
  task 'db:capture' => :environment do
    db = Rails.application.config.database_configuration[Rails.env]
    user = db['username']
    database = db['database']
    puts "[Forest] This command captures a snapshot of the Heroku database, downloads it, drops the local database and recreates if from the Heroku snapshot."
    puts "[Forest] Please run:"
    puts "heroku pg:backups:capture; heroku pg:backups:download; bin/rails db:drop; bin/rails db:create; pg_restore --verbose --clean --no-acl --no-owner -h localhost#{if user then " -U #{user}" end} -d #{database} latest.dump; rm latest.dump"
  end
end
