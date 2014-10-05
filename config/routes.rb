Rails.application.routes.draw do
  get "*path", to: "application#index"
  root 'application#index'
end
