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

    desc 'Refresh metadata for all files'
    task refresh_file_metadata: :environment do
      MediaItem.find_each do |media_item|
        attacher = media_item.attachment_attacher

        next unless attacher.stored? && media_item.file?

        attacher.refresh_metadata!
        media_item.save!
      end
    end
  end
end
