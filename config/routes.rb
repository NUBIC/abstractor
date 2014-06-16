Abstractor::Engine.routes.draw do
  resources :abstractor_abstraction_groups, only: [:create, :update, :destroy]

  resources :abstractor_abstractions do
    resources :abstractor_suggestions
  end
end