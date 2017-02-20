Rails.application.routes.draw do
  # Concerns
  concern :paginatable do
    get '(page/:page)', action: :index, on: :collection
  end

  # Root
  root to: 'public#index'

  # Admin
  get 'admin', to: 'admin#index'

  # Admin Resources
  scope :admin do
    resources :media_items do
      collection do
        post 'update_multiple'
      end
    end
    resources :menus, concerns: :paginatable
    resources :pages, concerns: :paginatable
    get 'pages/:id/versions', to: 'pages#versions', as: 'page_versions'
    get 'pages/:id/versions/:version_id', to: 'pages#version', as: 'page_version'
    get 'pages/:id/versions/:version_id/restore', to: 'pages#restore', as: 'restore_page_version'
    resources :settings
    resources :users
    resources :user_groups
  end

  # Devise
  devise_for :users, class_name: 'User', module: :devise

  devise_scope :user do
    get 'admin', to: 'devise/sessions#new'
    get 'login', to: 'devise/sessions#new'
    get 'logout', to: 'devise/sessions#destroy'
  end

  get 'user/:id', to: 'users#show', as: 'show_user'
  get 'media/:id', to: 'media_items#show', as: 'show_media_item'
  get ':id/edit', to: redirect('/admin/pages/%{id}/edit')
  get ':id', to: 'pages#show', as: 'show_page'
end
