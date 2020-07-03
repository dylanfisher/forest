Rails.application.routes.draw do
  # Errors
  match '404', to: 'errors#not_found', via: :all
  match '422', to: 'errors#unprocessable', via: :all
  match '500', to: 'errors#internal_server_error', via: :all

  # Admin Resources
  namespace :admin do
    get '/', to: 'dashboard#index'
    resources :block_kinds, only: [:index, :edit, :update], path: 'block-kinds'
    resources :block_layouts, except: [:destroy, :show, :new], path: 'block-layouts'
    resources :cache_purge, path: 'cache-purge', only: [:index]
    resources :imports, only: [:edit, :create]
    resources :media_items, except: [:show], path: 'media-items' do
      collection do
        post 'update_multiple'
      end
    end
    resources :menus, except: [:show]
    resources :pages, except: [:show]
    resources :settings, except: [:show, :destroy]
    resources :users, except: [:show] do
      get 'reset_password'
    end
    resources :user_groups, except: [:show, :destroy], path: 'user-groups'
    get 'documentation', to: 'documentation#index'
  end

  # Shrine direct S3 upload
  mount Shrine.presign_endpoint(:cache) => '/s3/params'

  # Devise
  devise_for :users, class_name: 'User', module: :devise
  devise_scope :user do
    get 'admin', to: 'devise/sessions#new'
    get 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
  end

  get '/edit', to: 'pages#edit'
  get '*page_path/edit', to: 'pages#edit'

  # Redirect wordpress spam
  get '/wp-login.php', to: redirect('/'), format: false
  get '/wp-content', to: redirect('/'), format: false
  get '/wp-admin', to: redirect('/'), format: false
  get '/wp-login', to: redirect('/'), format: false
  get '/wp-content/*all', to: redirect('/'), format: false
  get '/wp-admin/*all', to: redirect('/'), format: false
  get '/wp-login/*all', to: redirect('/'), format: false
  get '/xmlrpc.php', to: redirect('/'), format: false

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
