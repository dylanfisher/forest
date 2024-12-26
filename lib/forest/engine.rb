module Forest
  class Engine < ::Rails::Engine
    isolate_namespace Forest

    initializer 'forest.checking_migrations' do
      Migrations.new(config, engine_name).check
    end
  end
end
