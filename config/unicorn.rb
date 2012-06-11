APP_ROOT = File.dirname File.expand_path(File.dirname(__FILE__))

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', File.dirname(__FILE__))
require 'bundler/setup'

worker_processes 2
working_directory APP_ROOT

preload_app true

timeout 60

listen 8071, :backlog => 64

pid APP_ROOT + "/tmp/pids/unicorn.pid"

#user "deploy", "deploy"

stderr_path APP_ROOT + "/log/unicorn.stderr.log"
stdout_path APP_ROOT + "/log/unicorn.stdout.log"

GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = APP_ROOT + "/Gemfile"
end

before_fork do |server, _|
  old_pid = APP_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Old master already dead"
    end
  end
end

after_fork do |server, worker|
  child_pid = server.config[:pid].sub '.pid', ".#{worker.nr}.pid"
  system "echo #{Process.pid} > #{child_pid}"
end