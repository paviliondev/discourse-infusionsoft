# name: infusionsoft
# about: Integrate Infusionsoft with Discourse
# version: 0.1.2
# authors: Angus McLeod
# url: https://github.com/angusmcleod/infusionsoft-plugin

enabled_site_setting :infusionsoft_enabled

add_admin_route 'infusionsoft.title', 'infusionsoft'

register_asset 'stylesheets/common/infusionsoft.scss'

load File.expand_path('../lib/validators/allow_infusionsoft_enabled_validator.rb', __FILE__)

after_initialize do
  module ::Infusionsoft
    class Engine < ::Rails::Engine
      engine_name "infusionsoft"
      isolate_namespace Infusionsoft
    end
  end

  module ::Infusionsoft
    LOCAL_URL = "https://00542651.ngrok.io"

    TAG_GROUP_MAP = {
      348 => "6E",
      360 => "6J",
      352 => "CL",
      358 => "ES",
      470 => "GC",
      1085 => "NQ",
      1089 => "ZN",
      132 => "TR"
    }

    TRADING_ROOM_TAG = 132
  end

  require_dependency 'staff_constraint'

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

  load File.expand_path('../jobs/refresh_infusionsoft_access_token.rb', __FILE__)
  load File.expand_path('../jobs/infusionsoft_tag_group_sync.rb', __FILE__)
  load File.expand_path('../lib/infusionsoft/authorization.rb', __FILE__)
  load File.expand_path('../lib/infusionsoft/subscription.rb', __FILE__)
  load File.expand_path('../lib/infusionsoft/job.rb', __FILE__)
  load File.expand_path('../controllers/infusionsoft/admin.rb', __FILE__)
  load File.expand_path('../controllers/infusionsoft/authorization.rb', __FILE__)
  load File.expand_path('../controllers/infusionsoft/job.rb', __FILE__)
  load File.expand_path('../controllers/infusionsoft/subscription.rb', __FILE__)
end
