# config valid only for current version of Capistrano
lock '3.5.0'

set :repo_url, 'git@github.com:evercam/evercam-admin.git'
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :user, 'deployer'
set :application, 'evercam-admin'
set :rails_env, 'production'
server '88.99.226.17', user: "#{fetch(:user)}", roles: %w{app db web}, primary: true
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :pty, true

set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', 'config/puma.rb')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

set :config_example_suffix, '.example'
set :config_files, %w{config/database.yml config/secrets.yml}
set :puma_conf, "#{shared_path}/config/puma.rb"

set :nginx_config_name, 'evercam-admin'
set :nginx_server_name, 'happymin.evercam.io'
set :nginx_use_ssl, true

namespace :deploy do
  before 'check:linked_files', 'config:push'
  before 'check:linked_files', 'puma:config'
  before 'check:linked_files', 'puma:nginx_config'
  after 'puma:smart_restart', 'nginx:restart'
end
