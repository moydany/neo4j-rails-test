class MetricsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def index
    one_hour_ago = 1.hour.ago.to_i
    metrics = Metric.query_as(:m)
                    .where('m.timestamp > $one_hour_ago')
                    .params(one_hour_ago: one_hour_ago)
                    .pluck(:m)

    aggregated_metrics = metrics.group_by(&:key).map do |key, metrics|
      {
        name: key,
        total: metrics.sum(&:value)
      }
    end

    render json: aggregated_metrics
  end

  def create
    metric_params = params.require(:metric).permit(:name, :value)
    metric_attributes = metric_params.merge(timestamp: Time.now.to_i, key: params[:key])
    metric_attributes[:name] = "metric_#{next_index}" if metric_attributes[:name].blank?
    
    @metric = Metric.new(metric_attributes)
  
    if @metric.save
      render json: @metric, status: :created
    else
      render json: @metric.errors, status: :unprocessable_entity
    end
  end
  
  
  def show_all
    metrics = Metric.all
    render json: metrics
  end
  
  private  
  def metric_params
    params.require(:metric).permit(:name, :key, :value)
  end
  
end
