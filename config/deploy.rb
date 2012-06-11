set :application, "lsearch"
set :deploy_to, "/u/#{application}"

set :stages, %w( newservers )
set :default_stage, "newservers"
require 'capistrano/ext/multistage'

default_run_options[:pty] = true
set :repository, "git@github.com:NorthPointAdvisors/lsearch.git"
set :scm, "git"
set :deploy_via, :remote_cache

set :user, "deploy"
set :use_sudo, false

set :keep_releases, 5

require "bundler/capistrano"

set :bundle_gemfile, "Gemfile"
set :bundle_dir, fetch(:shared_path)+"/bundle"
set :bundle_flags, "--deployment --quiet"
set :bundle_without, [:development, :test]

