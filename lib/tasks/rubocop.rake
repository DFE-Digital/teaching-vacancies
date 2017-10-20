if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'

  desc 'Run rubocop - configure in .rubocop.yml'
  task :rubocop do
    RuboCop::RakeTask.new(:rubocop) do |t|
      t.options = ['--display-cop-names']
    end
  end

  task(:default).clear.enhance(%i[rubocop spec])
  task(:default).comment = 'Run rubocop checks'
end
