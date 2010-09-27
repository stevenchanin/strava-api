require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "strava"
    gem.summary = %Q{Provides a Ruby interface to the Strava api}
    gem.description = %Q{Strava (http://www.strava.com/) allows access to it's data via a JSON api.  This gem wraps that API an allows you to interact with Ruby classes instead.}
    gem.email = "steven_chanin@alum.mit.edu"
    gem.homepage = "http://github.com/stevenchanin/strava"
    gem.authors = ["Steven Chanin"]
    #not sure why files wasn't picking up subdirectors of lib when it seems to do so for hominid...
    gem.files = FileList['{lib,test}/**/*'] + %w(CHANGELOG.rdoc init.rb LICENSE Rakefile README.rdoc) - FileList['test/*.log']
    gem.add_dependency "httparty", " ~> 0.6.1"
    gem.add_dependency "mocha", " ~> 0.9.8"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "strava #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
