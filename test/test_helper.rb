require 'test/unit'
require 'rubygems'
require 'mocha'

class Project
  attr_accessor :name
  def self.plugin(plugin_name=nil)
    plugin_name ? @plugin_name = plugin_name : @plugin_name
  end
end

class Build
  attr_accessor :project, :label, :success, :time, :elapsed_time
  def failed?
    !@success
  end
end

module CruiseControl
  class Log
    def self.event(event_message=nil)
      event_message ? @event_message = event_message : @event_message
    end
  end
end

class DBI
end
