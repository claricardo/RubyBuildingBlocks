# This Rakefile has all the right settings to run the tests 
gem 'rspec', '~>3'
require 'rspec/core/rake_task'


def set_task_options(task, spec_file)
  app = Rake.application.original_dir
  task.pattern = "#{app}/spec/#{spec_file}"
  task.rspec_opts = [ "-I#{app}", '-f documentation', '-c']
  task.verbose = false
end


desc "run tests for caesar_cipher.rb"
RSpec::Core::RakeTask.new(:caesar_cipher) do |t|
  set_task_options(t, t.name.to_s + "_spec.rb")
end

desc "run tests for my_enumerables.rb"
RSpec::Core::RakeTask.new(:my_enumerables) do |t|
  set_task_options(t, t.name.to_s + "_spec.rb")
end

desc "run tests for tic_tac_toe.rb"
RSpec::Core::RakeTask.new(:tic_tac_toe) do |t|
  set_task_options(t, t.name.to_s + "_spec.rb")
end

desc "run tests for connect_four.rb"
RSpec::Core::RakeTask.new(:connect_four) do |t|
  set_task_options(t, t.name.to_s + "_spec.rb")
end