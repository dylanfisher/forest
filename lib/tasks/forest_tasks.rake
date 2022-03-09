namespace :forest do
  desc "Clear the Rails cache."
  task 'cache:clear' => :environment do
    Rails.cache.clear
  end
end
