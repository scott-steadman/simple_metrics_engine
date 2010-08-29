
Dir["#{Rails.root}/vendor/plugins/simple_metrics_engine/config/initializers/*.rb"].each do |file|
  require file
end
