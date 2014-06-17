Abstractor::Engine.routes.draw do
  resources :abstractor_abstraction_groups, only: [:create, :update, :destroy]

  resources :abstractor_abstractions do
    collection do
      put :update_all
    end
    resources :abstractor_suggestions
  end
end