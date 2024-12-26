Forest::Engine.routes.draw do
  root "welcome#index"

  resource :session
  resources :passwords, param: :token
end
