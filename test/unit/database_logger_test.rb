require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../../lib/database_logger'))

class DatabaseLoggerTest < Test::Unit::TestCase

  def test_registering_plugin
    assert_equal :database_logger, Project.plugin
  end

  def test_default_adapter
    logger = create_logger
    assert_equal 'Mysql', logger.adapter
  end
  
  def test_build_succeeds
    build = create_build
    logger = create_logger(:host => nil)
    logger.build_finished(build)
    statement = "INSERT INTO builds (project,svn_revision,build_number,success,duration,start) VALUES ('Test Project',13,2,1,17,'2008-12-23')"
    assert_equal "logging into database: #{statement}", CruiseControl::Log.event
  end
  
  def test_build_failed
    build = create_build(:success => false)
    logger = create_logger(:host => nil)
    logger.build_finished(build)
    statement = "INSERT INTO builds (project,svn_revision,build_number,success,duration,start) VALUES ('Test Project',13,2,0,17,'2008-12-23')"
    assert_equal "logging into database: #{statement}", CruiseControl::Log.event
  end
  
  def test_database_logging_if_parameter_is_missing
    build = create_build(:success => false)
    [:host, :username, :database].each do |parameter|
      logger = create_logger(parameter => nil)
      DBI.expects(:connect).never
      logger.build_finished(build)
    end
  end
  
  def test_database_logging
    build = create_build
    logger = create_logger(:database => 'database', :host => 'host', :username => 'username', :password => 'password')
    handler = 'database_handler'
    handler.expects(:do)
    DBI.expects(:connect).with('DBI:Mysql:database=database;host=host', 'username', 'password').yields(handler)
    logger.build_finished(build)
  end
  
  private
  
    def create_build(options={})
      project = Project.new
      project.name = options[:project_name] || 'Test Project'
      build = Build.new
      build.project = project
      build.success = options.key?(:success) ? options[:success] : true
      build.label = options[:label] || '13.2'
      build.time = options[:time] || '2008-12-23'
      build.elapsed_time = options[:elapsed_time] || '17'
      build
    end
    
    def create_logger(options={})
      logger = DatabaseLogger.new
      logger.host = options.key?(:host) ? options[:host] : 'dude'
      logger.username = options.key?(:username) ? options[:username] : 'dude'
      logger.password = options.key?(:password) ? options[:password] : ''
      logger.database = options.key?(:database) ? options[:database] : 'dude'
      logger
    end

end
