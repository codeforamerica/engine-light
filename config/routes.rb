EngineLight::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  resources :web_applications

  post 'persona/login' => 'persona#login'
  post 'persona/logout' => 'persona#logout'

  root 'welcome#index'
end
