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
    isolate_namespace Forest

    initializer :assets, :group => :all do
      Rails.application.config.assets.precompile += %w(
        forest/application_admin.css
        forest/application_public.css
        forest/application_admin.js
        forest/application_public.js
      )
    end

  end
end
