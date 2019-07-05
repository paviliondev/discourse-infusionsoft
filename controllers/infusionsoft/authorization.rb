class Infusionsoft::AuthorizationController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def callback
   Infusionsoft::Authorization.set_code(params[:code])
   Infusionsoft::Authorization.get_access_token

   redirect_to "/admin/plugins/infusionsoft"
  end
end
