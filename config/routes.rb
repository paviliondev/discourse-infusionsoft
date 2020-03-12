Discourse::Application.routes.prepend do
  mount ::Infusionsoft::Engine, at: 'infusionsoft'
  get '/admin/plugins/infusionsoft' => 'admin/plugins#index', constraints: StaffConstraint.new
end

Infusionsoft::Engine.routes.draw do
  get 'admin' => "admin#index"
  get 'authorization/callback' => "authorization#callback"
  post 'subscription' => "subscription#create"
  delete 'subscription' => "subscription#remove"
  post 'subscription/hook' => "subscription#hook"
  put 'subscription/verify' => "subscription#verify"
  put "job/start" => "job#start"
end