class Discord::AdminController < ::Admin::AdminController
  def index
    render_json_dump(jobs: Discord::Job.list)
  end
end
