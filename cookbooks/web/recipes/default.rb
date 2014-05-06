#
# Cookbook Name:: web
# Recipe:: default
#
# Copyright 2013, 
#

include_recipe 'apt'

##########
## Attributes
##########
node.set[:web][:repo_path] = node[:web][:repo_home] + node[:web][:repo_name]

##########
## PPAs
##########
## Dotdeb
apt_repository 'dotdeb' do
    uri          'http://packages.dotdeb.org'
    distribution 'wheezy'
    components   ['all']
    key          'http://www.dotdeb.org/dotdeb.gpg'
    action       :add
end

## PHP 5.5
apt_repository 'php5' do
    uri          'http://packages.dotdeb.org'
    distribution 'wheezy-php55'
    components   ['all']
    key          'http://www.dotdeb.org/dotdeb.gpg'
    action       :add
end

## Percona
apt_repository 'percona' do
    uri          'http://repo.percona.com/apt'
    distribution node['lsb']['codename']
    components   ['main']
    keyserver    'keys.gnupg.net'
    key          '1C4CBDCDCD2EFD2A'
    action       :add
end

## ElasticSearch
apt_repository 'elasticsearch' do
    uri          'http://packages.elasticsearch.org/elasticsearch/1.0/debian'
    distribution 'stable'
    components   ['main']
    key          'http://packages.elasticsearch.org/GPG-KEY-elasticsearch'
    action       :add
end

##########
## Packages
##########
%w{nginx git elasticsearch openjdk-7-jre-headless redis-server percona-server-server-5.6}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

%w{php5-fpm php5-cli php5-mcrypt php5-mysqlnd php5-curl}.each do |pkg|
    package pkg do
        action :upgrade
    end
end

## Composer
execute "curl -sS https://getcomposer.org/installer | php; mv ./composer.phar #{node[:web][:composer_bin]}" do
    cwd     '/tmp'
    creates node[:web][:composer_bin]
    not_if  { ::File.exists?(node[:web][:composer_bin])}
    action :run
end

file node[:web][:composer_bin] do
    owner 'root'
    group 'root'
    mode  00755
end

##########
## ElasticSearch
##########
service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
    action   [:enable, :start]
end

template '/etc/elasticsearch/elasticsearch.yml' do
    source 'elasticsearch.yml.erb'
    owner  'root'
    group  'root'
    mode   '0644'
    action :create
end

##########
## Clone Repository
##########
execute "git clone -b #{node[:web][:repo_branch]} #{node[:web][:repo]} #{node[:web][:repo_path]}" do
    user   'vagrant'
    group  'vagrant'
    not_if { ::File.exists?(node[:web][:repo_path])}
    action :run
end

##########
## Nginx
##########
## Create Nginx Site Conf
template '/etc/nginx/sites-available/site' do
    source 'site.conf.erb'
    owner  'root'
    group  'root'
    mode   '0755'
    variables(
        :home   => node[:web][:repo_path],
        :name   => node[:web][:repo_name],
        :socket => node[:web][:composer_sock]
    )
    notifies :create, 'link[/etc/nginx/sites-enabled/site]', :immediately
    action   :create
end

## Enable Site
link '/etc/nginx/sites-enabled/site' do
    to       '/etc/nginx/sites-available/site'
    notifies :restart, 'service[nginx]', :immediately
    action   :nothing
end

## Reload Nginx Service
service 'nginx' do
    supports :status => true, :restart => true, :reload => true
    action   :nothing
end

##########
## SQL Database
##########
execute 'mysql -u root -e "CREATE DATABASE IF NOT EXISTS radio"' do
    action :run
end

##########
## Composer Stuff
##########
## Copy configs
%w{app database}.each do |conf|
    execute "cp #{conf}.php.sample #{conf}.php" do
        cwd   node[:web][:repo_path] + '/app/config/'
        user  'vagrant'
        group 'vagrant'
        not_if { ::File.exists?(node[:web][:repo_path] + "/app/config/#{conf}.php")}
        action :run
    end
end

execute "#{node[:web][:composer_bin]} install" do
    cwd    node[:web][:repo_path]
    user   'vagrant'
    group  'vagrant'
    environment ({'COMPOSER_HOME' => '/home/vagrant'})
    action :run
end

# execute "php artisan migrate" do
#     cwd    node[:web][:repo_path]
#     user   'vagrant'
#     group  'vagrant'
#     action :run
# end
