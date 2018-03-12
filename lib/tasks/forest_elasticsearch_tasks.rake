require 'elasticsearch/rails/tasks/import'

namespace :forest do
  namespace :elasticsearch do
    desc 'Rebuild the elasticsearch indices and import all searchable models.'
    task rebuild: :environment do
      SearchIndexManager.rebuild
    end

    desc 'Import all searchable models into elasticsearch.'
    task import: :environment do
      if ENV['FORCE']
        SearchIndexManager.create_index(force: ENV['FORCE'])
      end

      SearchIndexManager.import
    end
  end
end
