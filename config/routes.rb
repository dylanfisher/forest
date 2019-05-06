Rails.application.routes.draw do
  # Errors
  match '404', to: 'errors#not_found', via: :all
  match '422', to: 'errors#unprocessable', via: :all
  match '500', to: 'errors#internal_server_error', via: :all

  # Admin Resources
  namespace :admin do
    get '/', to: 'dashboard#index'
    resources :block_layouts, except: [:destroy], path: 'block-layouts'
    resources :cache_purge, path: 'cache-purge', only: [:index]
    resources :imports, only: [:edit, :create]
    resources :media_items, path: 'media-items' do
      collection do
        post 'update_multiple'
      end
    end
    resources :menus
    resources :pages
    resources :settings, except: [:destroy]
    resources :translations
    resources :users do
      get 'reset_password'
    end
    resources :user_groups, except: [:destroy], path: 'user-groups'
    get 'documentation', to: 'documentation#index'
  end

  # Devise
  devise_for :users, class_name: 'User', module: :devise
  devise_scope :user do
    get 'admin', to: 'devise/sessions#new'
    get 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
  end

  # Show
  get 'user/:id', to: 'users#show', as: 'user'
  get 'media/:id', to: 'media_items#show', as: 'media_item'

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

  scope constraints: lambda { |request|
    ['text/html', '*/*'].include?(request.format.to_s) &&
    (request.path =~ /^\/admin\//).nil?
  } do
    get '*page_path', to: 'pages#show', as: 'page'
  end
end
