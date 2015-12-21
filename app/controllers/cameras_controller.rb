class CamerasController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.all.includes(:user, vendor_model: [:vendor]).decorate
  end

  def show
    @camera = Camera.find(params[:id]).decorate
  end

  def merge
    @cameras = Camera.run_sql("select config->>'external_http_port' as external_http_port, config->>'external_host' as external_host, config->'snapshots'->>'jpg'   as jpg, count(*) as count from cameras group by config->>'external_http_port', config->>'external_host', config->'snapshots'->>'jpg' HAVING (COUNT(*)>1)")
  end
end
