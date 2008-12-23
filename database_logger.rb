class NilClass
  def empty?
    nil?
  end
end
class DatabaseLogger
  attr_accessor :host, :adapter, :database, :username, :password
  
  def initialize(project = nil)
    @adapter = 'Mysql'
  end
  
  def build_finished(build)
    return if @host.empty? || @username.empty? || @database.empty?
    DBI.connect("DBI:#{@adapter}:database=#{@database};host=#{@host}", @username, @password || '') do |dbh|
      revision, build_number = build.label.split('.')
      insert_sql = "INSERT INTO builds (project,svn_revision,build_number,success,duration,start) 
                    VALUES (#{build.project.name},#{revision},#{build_number},#{build.failed? ? '0' : '1'},#{build.elapsed_time},#{build.time})"
      # dbh.do(insert_sql)
      puts insert_sql
    end
  end
  
  
end

Project.plugin :database_logger
