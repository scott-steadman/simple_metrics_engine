
Dir["#{Rails.root}/config/initializers/*.rb"].each do |file|
  require file
end
