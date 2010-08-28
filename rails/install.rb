
# copy migrations
Dir["#{Rails.root}/vendor/plugins/simple_metrics_engine/db/migrate/*.rb"].each do |file|
  puts "Copying #{File.basename(file)} to db/migrate"
  FileUtils.cp(file, "#{Rails.root}/db/migrate")
end

sh 'rake db:migrate'