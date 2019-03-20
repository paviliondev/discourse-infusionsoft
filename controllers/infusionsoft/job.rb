class Infusionsoft::JobController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def start
    Jobs.enqueue("infusionsoft_#{params[:job]}".to_sym)
  end
end
