# name: discourse-infusionsoft
# about: Integrate Infusionsoft with Discourse
# version: 0.2.1
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-infusionsoft

enabled_site_setting :infusionsoft_enabled

add_admin_route 'infusionsoft.title', 'infusionsoft'

register_asset 'stylesheets/common/infusionsoft.scss'

load File.expand_path('../lib/validators/allow_infusionsoft_enabled_validator.rb', __FILE__)

after_initialize do
  %w[
    ../lib/infusionsoft/engine.rb
    ../lib/infusionsoft/authorization.rb
    ../lib/infusionsoft/subscription.rb
    ../lib/infusionsoft/helper.rb
    ../lib/infusionsoft/log.rb
    ../jobs/refresh_infusionsoft_access_token.rb
    ../jobs/infusionsoft_tag_group_sync.rb
    ../controllers/infusionsoft/admin.rb
    ../controllers/infusionsoft/authorization.rb
    ../controllers/infusionsoft/job.rb
    ../controllers/infusionsoft/subscription.rb
    ../config/routes.rb
  ].each do |path|
    load File.expand_path(path, __FILE__)
  end
end
