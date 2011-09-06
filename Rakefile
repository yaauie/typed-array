# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "typed-array"
  gem.homepage = "http://github.com/yaauie/typed-array"
  gem.license = "MIT"
  gem.summary = %Q{Provides methods for creating type-enforced Arrays}
  gem.description =<<-DESCRIPTION
      All methods that alter the contents of an array that implements this Gem are first checked to
      ensure that the added items are of the types allowed. All methods behave exactly as their Array
      counterparts, including additional forms, block processing, etc.

      Defining a TypedArray Class:

      ```ruby
      class ThingsArray < Array
        extend TypedArray
        restrict_types Thing1, Thing2
      end

      things = ThingsArray.new
      ```

      Generating a single TypedArray

      ```ruby
      things = TypedArray(Thing1,Thing2).new

      These classes can be extended, and their accepted-types appended to after their initial definition.
    DESCRIPTION
  gem.email = "ruby-dev@yaauie.com"
  gem.authors = ["Ryan Biesemeyer"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "typed-array #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
