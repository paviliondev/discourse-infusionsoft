# name: discord
# about: Integrate Discord with Discourse
# version: 0.1
# authors: Angus McLeod
# url: https://github.com/angusmcleod/discord-plugin

enabled_site_setting :discord_enabled

add_admin_route 'discord.title', 'discord'

register_asset 'stylesheets/common/discord.scss'

load File.expand_path('../lib/validators/allow_discord_enabled_validator.rb', __FILE__)

after_initialize do
  module ::Discord
    class Engine < ::Rails::Engine
      engine_name "discord"
      isolate_namespace Discord
    end
  end

  require_dependency 'staff_constraint'
  Discourse::Application.routes.prepend do
    mount ::Discord::Engine, at: 'discord'
    get '/admin/plugins/discord' => 'admin/plugins#index', constraints: StaffConstraint.new
  end

  Discord::Engine.routes.draw do
    get 'admin' => "admin#index"
    put "job/start" => "job#start"
  end

  load File.expand_path('../jobs/discord_sync_group_with_role.rb', __FILE__)
  load File.expand_path('../lib/discord/discord.rb', __FILE__)
  load File.expand_path('../lib/discord/job.rb', __FILE__)
  load File.expand_path('../lib/discord/sync.rb', __FILE__)
  load File.expand_path('../controllers/discord/admin.rb', __FILE__)
  load File.expand_path('../controllers/discord/job.rb', __FILE__)

  #module ExtendDiscordAuth
    #def after_authenticate(auth_token)
      #result = super(auth_token)
      #result.extra_data[:uid] = auth_token[:uid]
      #result
    #end

    #def after_create_account(user, auth)
      #user.
    #end
  #end

  #class DiscordAuthenticator
    #prepend ExtendDiscordAuth
  #end
end
