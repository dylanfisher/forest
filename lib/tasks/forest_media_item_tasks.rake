namespace :forest do
  namespace :media do
    desc 'Reprocess all derivatives for every media item'
    task reprocess_all: :environment do
      MediaItem.reprocess_all_derivatives!
    end

    desc 'Reprocess derivatives for media items that are missing derivatives'
    task reprocess_missing: :environment do
      MediaItem.reprocess_missing_derivatives!
    end
  end
end
