require 'rake/testtask'
require 'rubocop/rake_task'

task default: %i(style test)

RuboCop::RakeTask.new(:style)

Rake::TestTask.new(:test) do |test|
  test.test_files = FileList[
    'test/test*.rb',
    'test/**/test*.rb'
  ]
end
