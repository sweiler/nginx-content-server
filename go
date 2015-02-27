#!/usr/bin/env ruby
require 'thor'

REQUIRED_DOCKER = '1.0.1'


class GoScript < Thor

  desc 'checkdeps', 'Check if all dependencies are installed.'
  def checkdeps
    check_docker
    check_redis_image
  end
  
  desc 'build [--no-cache]', 'Build the docker image for the server.'
  method_option :cache, :desc => 'Use cached state for building the container.', :type => :boolean, :default => true
  def build
    if options[:cache]
      exec 'docker build -t sweiler/uucs .'
    else
      exec 'docker build --no-cache=true -t sweiler/uucs .'
    end
  end
  
  desc 'up [--no-volumes]', 'Launch the server.'
  method_option :volumes, :desc => 'Link volumes to host for development.', :type => :boolean, :default => true
  def up
    image_test = `docker images | grep 'sweiler/uucs'`
    if image_test.length < 20
      puts 'No sweiler/uucs image found. Run ./go build first.'
      exit
    end
    
    launch_redis
    exists_container = `docker ps -a | awk '{print $2}' | grep 'uucs-web'`.strip
    if exists_container.length > 10
      simple_start = `docker start uucs-web`
      if $?.success?
        puts '[OK]  Server started using old container.'
        exit
      end
    end
    
    if options[:volumes]
      workingdir = `pwd`.strip
      id = `docker run -d -p 8080:8080 -p 8081:80 -v #{workingdir}/admin_port:/app/admin_port --name uucs-web --link uucs-redis:redis -i sweiler/uucs`
    else
      id = `docker run -d -p 8080:8080 -p 8081:80 --name uucs-web --link uucs-redis:redis -i sweiler/uucs`
    end
    
    puts '[OK] Server started, created a new container.'
  end
  
  desc 'stop [--redis]', 'Stops the server.'
  method_option :redis, :desc => 'Stop redis too. This invalidates all tokens.', :type => :boolean, :default => false
  def stop
    exists_container = `docker ps -a | awk '{print $2}' | grep 'sweiler/uucs'`.strip
    if exists_container.length > 10
      `docker stop uucs-web`
    end
    if options[:redis]
      exists_redis = `docker ps -a | grep 'uucs-redis'`.strip
      if exists_redis.length > 10
        `docker stop uucs-redis`
      end
    end
    
  end
  
  desc 'nuke', 'Removes the current container. ALL DATA LOST IF NOT BACKED UP!'
  def nuke
    exec 'docker rm -f uucs-web'
  end
  
  private
  
  def parse_version (str)
    version_id = str[/[0-9]+(\.[0-9]+)+/]
    version_id.split(/\./)
  end
  
  def version_compatible? (required, current)
    required_parts = required.split(/\./)
    accepted = true
    current.zip(required_parts).each do |current, required|
      if current.to_i < required.to_i
        accepted &= false
      end
    end
    return accepted
  end
  
  def check_docker   
    `which docker`
    if $?.success?
      dockerstr = `docker -v`
      docker_version = parse_version(dockerstr)
      
      if version_compatible?(REQUIRED_DOCKER, docker_version)
        puts "[OK]  Docker found with version #{docker_version.join('.')}"
      else
        puts "[WARN]  Your version (#{docker_version.join('.')}) of docker is incompatible. Upgrade to v >= #{REQUIRED_DOCKER}."
      end
    else
      puts '[ERROR]  You have to install docker. Try "./go installdeps"'
      exit
    end
  end
  
  def check_redis_image
    redis_versions = `docker images | grep 'redis' | awk '{print $2}'`.each_line.to_a.map! {|l| l.strip}
    if redis_versions.include? 'latest'
      puts '[OK]  Latest version of redis for docker is installed.'
    else
      puts '[ERROR]  You have to download the latest version of redis for docker. Try "./go installdeps".'
    end
  end
  
  def launch_redis
    redis_created = `docker ps -a | grep 'uucs-redis' | awk '{print $1}'`.strip
    redis_running = `docker ps | grep 'uucs-redis' | awk '{print $1}'`.strip
    if redis_created.length > 5
      if redis_running == redis_created
        puts '[OK]  Redis running'
      else
        redis_started = `docker start #{redis_created}`.strip
        if redis_started == redis_created
          puts '[OK] Redis running'
        else
          puts "[ERROR] Launch of existing redis failed: #{redis_started}"
          exit
        end
      end
    else
      id = `docker run -d --name uucs-redis -i redis:latest`.strip
      if id.length != 64
        puts "[ERROR]  Creation of redis failed: #{id}"
        exit
      end
      puts '[OK]  Redis running'
    end
  end

end

GoScript.start ARGV


