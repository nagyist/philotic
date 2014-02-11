$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'support'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'config'))


require 'rubygems'
require 'bundler/setup'
require 'philotic'

Bundler.require(:default, :test)

RSpec.configure do |config|
  #Run any specs tagged with focus: true or all specs if none tagged
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.after do
    Timecop.return
  end
  
end
#Philotic.logger = Logger.new("/dev/null")
