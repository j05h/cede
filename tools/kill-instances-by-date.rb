#!/usr/bin/env ruby

require 'time'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} -p|--project -c|--creds [-u|--units] [-t|--time] [-h|--help]"

  options[:project] = nil
  opts.on( '-p', '--project PROJECT', 'Project to scan for old instances. Required for, and only works with, -a') do |project|
    options[:project] = project
  end

  options[:creds] = nil
  opts.on( '-c', '--creds CREDS', 'Credentials file to use when checking for running instances') do |creds|
    options[:creds] = creds
  end

  options[:units] = "days"
  opts.on( '-u', '--units [minutes|hours|days]', [:minutes, :hours, :days], 'Units to calculate the instance age in (combine with -t). Defaults to days') do |units|
    options[:units] = units.to_s
  end

  options[:time] = "30"
  opts.on( '-t', '--time UNITS', 'Kill an instance if it\'s older than this many units (combined with -u). Defaults to 30') do |days|
    options[:time] = days.to_i
  end

  options[:admin] = false
  opts.on( '-a', '--admin', 'Set this option if you are running as a nova admin user' ) do
    options[:admin] = true
  end

  opts.on( '-h', '--help', 'Display this help screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

# These options are required
unless options[:creds]
  puts "You must specify your credentials file"
  puts optparse
  exit
end

project = options[:project]
creds = options[:creds]

# Get our list of instances
if (options[:admin])
  unless project
    puts "When running in admin mode you must specify -p"
    exit 1
  end
  instances = `source #{creds} && euca-describe-instances | grep #{project} | awk '/INSTANCE/ {print $2, $(NF-1)}'`
else
  instances = `source #{creds} && euca-describe-instances | awk '/INSTANCE/ {print $2, $(NF-1)}'`
end

units = case options[:units]
  when "minutes"
     60
  when "hours"
     60 * 60
  when "days"
     60 * 60 * 24
  end

offset =  options[:time] * 
# Array to hold instances we want to kill
kill_instances = []

# Create an array and iterate over it
kill_date = Time.now - offset
instances.split("\n").each do |instance|
  instance_id, launch_date = instance.split(/\s+/)
  kill_instances << instance_id if kill_date > Time.parse(launch_date)
end

puts "euca-terminate-instances #{kill_instances.join(' ')}"
