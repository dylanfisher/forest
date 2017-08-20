Rails.application.routes.draw do
  # Errors
  match '404', to: 'errors#not_found', via: :all
  match '500', to: 'errors#internal_server_error', via: :all

  # Root
  root to: 'public#index'

  # Admin Resources
  namespace 'admin' do
    get '/', to: 'dashboard#index'
    resources :cache_purge, path: 'cache-purge', only: [:index]
    resources :imports, only: [:edit, :create]
    resources :media_items, path: 'media-items' do
      collection do
        post 'update_multiple'
      end
    end
    resources :menus
    resources :pages
    resources :settings
    resources :users
    resources :user_groups, path: 'user-groups'

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
  get 'user/:id', to: 'users#show', as: 'show_user'
  get 'media/:id', to: 'media_items#show', as: 'show_media_item'

  get '*page_path/edit', to: 'pages#edit'
  # get '*page_path/edit', to: redirect('/admin/pages/%{page_path}/edit'), constraints: { page_path: /(?!.*admin).*/ }

  scope constraints: lambda { |request| request.format.to_s.include? 'text/html' } do
    get '*page_path', to: 'pages#show', as: 'show_page'
  end
end
