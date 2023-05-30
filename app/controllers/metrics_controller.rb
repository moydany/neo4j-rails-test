class MetricsController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def create
    metric_params = params.require(:metric).permit(:value)
    metric_attributes = metric_params.merge(timestamp: Time.now.to_i, key: params[:key])
    
    next_index = Metric.count + 1
    metric_name = params.dig(:metric, :name) || "metric_#{next_index}"
    
    metric_attributes[:name] = metric_name
  
    if Metric.exists?(key: metric_attributes[:key])
      render json: { error: "A metric with this key already exists" }, status: :conflict
      return
    end
  
    @metric = Metric.new(metric_attributes)
    
    if @metric.save
      render json: @metric, status: :created
    else
      render json: @metric.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @metric = Metric.find_by(key: params[:key])
    
    if @metric
      @metric.destroy
      render json: { message: "Metric successfully deleted" }, status: :ok
    else
      render json: { error: "Metric not found" }, status: :not_found
    end
  end
  
  def show_all
    metrics = Metric.all
    render json: metrics
  end

  def show_by_name
    @metrics = Metric.where(name: params[:name])
  
    if @metrics.any?
      render json: @metrics, status: :ok
    else
      render json: { error: "Metrics not found" }, status: :not_found
    end
  end
  
  def show_by_key
    @metric = Metric.find_by(key: params[:key])
  
    if @metric
      render json: @metric, status: :ok
    else
      render json: { error: "Metric not found" }, status: :not_found
    end
  end

  def aggregate
    one_hour_ago = 1.hour.ago.to_i
    metrics = Metric.query_as(:m)
                    .where('m.timestamp > $one_hour_ago')
                    .params(one_hour_ago: one_hour_ago)
                    .pluck(:m)
  
    aggregated_metrics = metrics.group_by(&:name).map do |name, metrics|
      {
        name: name,
        total: metrics.sum(&:value)
      }
    end
  
    render json: aggregated_metrics
  end  

  private  
  def metric_params
    params.require(:metric).permit(:name, :key, :value)
  end
end
