require 'rubocop/rake_task'

desc 'Run rubocop - configure in .rubocop.yml'
task :rubocop do
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end
end
