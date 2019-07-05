class Infusionsoft::AdminController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def index
    data = {
      authorized: Infusionsoft::Authorization.authorized,
      access_token: Infusionsoft::Authorization.access_token[:token],
      access_token_expires_at: Infusionsoft::Authorization.access_token[:expires_at],
      access_token_refresh_at: Infusionsoft::Authorization.access_token[:refresh_at],
      refresh_token: Infusionsoft::Authorization.refresh_token,
      code: Infusionsoft::Authorization.code
    }

    if Infusionsoft::Authorization.authorized
      data[:subscriptions] = Infusionsoft::Subscription.list
      data[:jobs] = Infusionsoft::Job.list
    end

    render_json_dump(data)
  end
end
