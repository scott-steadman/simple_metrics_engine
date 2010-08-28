
puts 'Running install script...'

# copy migrations
FileUtils.mkdir_p("#{Rails.root}/db/migrate")
Dir["#{Rails.root}/vendor/plugins/simple_metrics_engine/db/migrate/*.rb"].each do |file|
  puts "Copying #{File.basename(file)} to db/migrate"
  FileUtils.cp(file, "#{Rails.root}/db/migrate")
end

`rake db:migrate`
