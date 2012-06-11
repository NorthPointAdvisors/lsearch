begin
  require 'yajl/json_gem'
rescue LoadError
  require 'json'
end

require File.expand_path(File.dirname(__FILE__) + '/log_file')
require File.expand_path(File.dirname(__FILE__) + '/line_processor')
require File.expand_path(File.dirname(__FILE__) + '/line_filter')

class App

  ROOT = Dir.pwd
  #puts ">> ROOT   : #{ROOT}"
  PUBLIC = "#{ROOT}/public"
  #puts ">> PUBLIC : #{PUBLIC}"

  include Presto

  http.map

  http.content_type(:tail, :grep) { 'application/json' }

  def index(*args)
    if args.empty?
      #puts "index : args #{args.inspect} : serving index.html ..."
      serve_file "index.html"
    else
      path = path_for args
      #puts "index : args #{args.inspect} : found path : #{path} ..."
      if File.file? path
        #puts "index : args #{args.inspect} : serving static #{path} ..."
        serve_file path
      else
        #puts "index : args #{args.inspect} : [[ ERROR ]] serving 404 for #{path} ..."
        http.error(404, 'File not found')
      end
    end
  end

  def app_names(*args)
    #puts "app_names : args #{args.inspect}"
    LogFile.app_names.to_json
  end

  def dates(*args)
    #puts "dates : args #{args.inspect}"
    LogFile.dates.to_json
  end

  def grep(*args)
    #puts " grep | args #{args.inspect} | params : #{http.params.inspect} ".center(120, "=")
    app_name = args[0].to_s.strip
    date_str = http.params[:date].to_s.strip
    #puts "grep : app_name [#{app_name}] : date_str [#{date_str}]"
    if LogFile.has_app?(app_name)
      if date_str.empty?
        { :status => :error, :message => "Date range was missing" }.to_json
      else
        log = LogFile.first app_name, date_str
        if log
          options      = {
            :offset  => http.params[:offset],
            :limit   => http.params[:limit],
            :filters => { },
          }
          main_filter = http.params[:main].to_s.strip
          unless main_filter.empty?
            options[:filters][:main] = main_filter
            #puts "Filtering by #{options[:filter].inspect} ..."
          end
          hsh          = log.grep options
          hsh[:status] = :success
          hsh.to_json
        else
          { :status => :error, :message => "Log file for [#{app_name} #{date_str}] was not found" }.to_json
        end
      end
    else
      { :status => :error, :message => "App [#{app_name}] was not found" }.to_json
    end
  end

  def tail(*args)
    #puts "tail : args #{args.inspect}"
    { }.to_json
  end

  private

  def path_for(parts)
    #puts "path_for : #{parts.inspect} (#{parts.class.name})"
    "#{PUBLIC}/#{parts.join("/")}"
  end

  def serve_file(path)
    #puts "serve_file : #{path} ..."
    new_path = path[0, PUBLIC.size] == PUBLIC ? path : "#{PUBLIC}/#{path}"
    new_path.gsub! '..', ''
    #puts "serving file #{new_path} ..."
    http.send_file new_path
  end

end