Rails.application.routes.draw do
  # Errors
  match '404', to: 'errors#not_found', via: :all
  match '422', to: 'errors#unprocessable', via: :all
  match '500', to: 'errors#internal_server_error', via: :all

  # Admin Resources
  namespace :admin do
    get '/', to: 'dashboard#index'
    get '/forest', to: redirect('/admin')
    resources :block_kinds, only: [:index, :edit, :update], path: 'block-kinds'
    resources :block_layouts, except: [:destroy, :show, :new], path: 'block-layouts'
    resources :cache_purge, path: 'cache-purge', only: [:index]
    resources :imports, only: [:edit, :create]
    resources :media_items, except: [:show], path: 'media-items' do
      post 'update_multiple', on: :collection
      post 'reprocess', on: :member
      patch 'transcode', on: :member
    end
    resources :menus, except: [:show]
    resources :pages, except: [:show]
    resources :redirects, except: [:show]
    resources :settings, only: [:index, :edit, :update]
    resources :users, except: [:show] do
      get 'reset_password'
    end
    resources :user_groups, except: [:show, :destroy], path: 'user-groups'
    post 'position_updater', to: 'position_updater#update'
    get 'documentation', to: 'documentation#index'
  end

  # Shrine direct S3 multipart upload
  begin
    mount Shrine.uppy_s3_multipart(:cache) => '/s3/multipart'
  rescue Shrine::Error => e
    puts "[Forest][Error] Shrine cache must be configured. Define S3 options in Rails credentials file.\n#{e.inspect}" if Rails.env.development?
  end

  # Devise
  unless Forest.override_devise_for_route_declaration
    devise_for :users, class_name: 'User', module: :devise
    devise_scope :user do
      get 'admin', to: 'devise/sessions#new'
      get 'login', to: 'devise/sessions#new'
      get 'logout', to: 'devise/sessions#destroy'
    end
  end

  get '/edit', to: 'pages#edit'
  get '*page_path/edit', to: 'pages#edit'

  # Redirect wordpress spam
  match '/wp-login.php', to: redirect('/'), format: false, via: :all
  match '/wp-cron.php', to: redirect('/'), format: false, via: :all
  match '/wp-load.php', to: redirect('/'), format: false, via: :all
  match '/wp-content', to: redirect('/'), format: false, via: :all
  match '/wp-admin', to: redirect('/'), format: false, via: :all
  match '/wp-login', to: redirect('/'), format: false, via: :all
  match '/wp-content/*all', to: redirect('/'), format: false, via: :all
  match '/wp-includes/*all', to: redirect('/'), format: false, via: :all
  match '/wp-json/*all', to: redirect('/'), format: false, via: :all
  match '/wp-admin/*all', to: redirect('/'), format: false, via: :all
  match '/wp-login/*all', to: redirect('/'), format: false, via: :all
  match '/xmlrpc.php', to: redirect('/'), format: false, via: :all

  scope constraints: lambda { |request|
    ['text/html', '*/*'].include?(request.format.to_s) &&
    (request.path =~ /^\/admin\//).nil?
  } do
    scope '(:locale)',
          locale: /#{I18n.available_locales.join('|')}/,
          defaults: {
            locale: (I18n.locale == I18n.default_locale ? nil : I18n.locale) } do
      get '*page_path', to: 'pages#show', as: 'page'
    end
  end
end
