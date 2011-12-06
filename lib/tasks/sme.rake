namespace :sme do

  desc 'Generate rollups (from=<from time>, to=<to time>)'
  task :rollup_logs => [:environment] do
    Sme::Rollup.update_metrics(:from => ENV['from'], :to => ENV['to'], :verbose => true)
  end

  desc 'Annotate models'
  task :annotate do
    sh "annotate -p before -i -e tests"
  end

  desc 'Generate coverage report'
  task :coverage => [:environment] do
    excludes = %w[boot.rb config vendor].join(',')
    output_dir = "#{Rails.root}/public/coverage"
    rm_rf(output_dir)
    files = Dir['test/{unit,functional}/**/*_test.rb'].join(' ')
    sh "rcov --rails -t --sort coverage -o public/coverage -x 'gems' #{files}"
  end

  desc 'Generate dummy data for testing (count=<count default 1000>)'
  task :generate_dummy_data => [:environment] do
    events = ['one|one|one', 'one|one|two', 'one|two|one', 'one|two|two', 'two|one', 'two|two']
    count = ENV['count'] ? ENV['count'].to_i : 1000
    start = Time.now.beginning_of_day - 4.days
    max = Time.now.to_i - start.to_i
    count.times do
      Sme::Log.create!(:event => events[rand(events.size)], :created_at => Time.at(start + rand(max)))
      $stderr << '.'
    end
    puts ''
    Sme::Rollup.update_metrics(:from => start, :to => Time.now, :verbose => true)
  end

end # namespace sme
