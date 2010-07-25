desc 'Annotate models'
task :annotate do
  sh "annotate -p before -i -e tests"
end

namespace :test do
  desc 'Generate coverage report'
  task :coverage => [:environment] do
    excludes = %w[boot.rb config vendor].join(',')
    output_dir = "#{Rails.root}/public/coverage"
    files = Dir['test/{unit,functional}/**/*_test.rb'].join(' ')
    rm_rf(output_dir)
    sh "rcov --rails -t --sort coverage -o public/coverage #{files}"
  end

end
