require 'rubygems'
require 'bundler'
require 'pathname'

Bundler.require

task :cleanup do
  puts ">> Clean old css files ..."
  `rm -f public/assets/css/*`
  puts ">> Clean old js files ..."
  `rm -rf public/assets/js/*`
end

desc "Compile all assets with Sprockets"
task :compile => :cleanup do
  puts ">> Compile JS assets ..."
  `coffee -o public/assets/js -c assets/js/app.coffee`
  `juicer merge -f -s -t js -o public/assets/js/all.js assets/js/all.js`
  puts ">> Compile CSS assets ..."
  `juicer merge -f -s -t css -o public/assets/css/all.css assets/css/all.css`
  `cp assets/css/app.css public/assets/css/app.css`
end

task :default => :compile