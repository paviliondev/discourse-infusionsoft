class Discord::JobController < ::Admin::AdminController
  def start
    Discord::Sync.start(job_params.to_h)
    render json: success_json
  end

  def job_params
    params.permit(
      :group,
      :role
    )
  end
end
