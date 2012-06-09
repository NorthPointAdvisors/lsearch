require 'presto'
require File.expand_path(File.dirname(__FILE__) + '/lib/app')

run Presto.new.to_app