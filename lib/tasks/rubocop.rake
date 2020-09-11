if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'

  desc 'Run rubocop - configure in .rubocop.yml'
  # Docs say this can be safely ignored/skipped if the task does not require an environment. Rubocop does not.
  task :rubocop do
    RuboCop::RakeTask.new(:rubocop) do |t|
      t.options = ['--display-cop-names']
    end
  end

  task(:default).clear.enhance(%i[rubocop spec])
end
