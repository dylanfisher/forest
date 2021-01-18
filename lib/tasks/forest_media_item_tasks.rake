namespace :forest do
  namespace :media do
    desc 'Reprocess all derivatives for every media item'
    task reprocess_all: :environment do
      MediaItem.reprocess_all!
    end
  end
end
