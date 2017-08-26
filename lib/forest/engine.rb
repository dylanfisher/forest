Gem.loaded_specs['forest'].runtime_dependencies.each do |dependency|
  begin
    require dependency.name
  rescue LoadError => load_error
    # Put exceptions here.
    # raise load_error if dependency.name !~ /gem_name/
  end
end

module Forest
  class Engine < ::Rails::Engine
    config.autoload_paths << "#{config.root}/app/models/blocks"

    initializer :assets, group: :all do
      Rails.application.config.assets.precompile += %w(
        forest/application_admin.css
        forest/application_public.css
        forest/application_bootstrap.css
        forest/application_admin.js
        forest/application_public.js
        forest/lib/jquery-3.2.1.min.js
        jquery2.js
        forest/favicons/apple-touch-icon.png
        forest/favicons/favicon-32x32.png
        forest/favicons/favicon-16x16.png
        forest/favicons/manifest.json
        forest/favicons/safari-pinned-tab.svg
      )
    end

    config.after_initialize do
      'Setting'.safe_constantize&.initialize_from_i18n
      'Translation'.safe_constantize&.initialize_from_i18n
    end
  end
end
