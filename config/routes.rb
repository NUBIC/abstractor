Abstractor::Engine.routes.draw do
  resources :abstractor_abstraction_groups, only: [:create, :update, :destroy]

  resources :abstractor_abstractions do
    collection do
      put :update_all
    end
    resources :abstractor_suggestions
  end

  resources :abstractor_abstraction_schemas, only: [:show]
  resources :abstractor_abstraction_schema_sources, except: [:new, :create, :edit, :update, :index, :show, :destroy] do
    collection do
      post :configure_and_store_abstractions
    end
  end
end