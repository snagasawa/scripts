#! /usr/bin/env ruby
require 'net/http'
require 'json'
require 'time'

MACKEREL_API_LOCATION = 'https://mackerel.io/api/v0'.freeze

class API
  def initialize(api_key)
    @api_key = api_key
  end

  def get_json(url)
    request = Net::HTTP::Get.new(url.path)
    request['X-Api-Key'] = @api_key
    request['Content-Type'] = 'application/json'

    response = Net::HTTP.start(url.host, url.port, use_ssl: url.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.request(request)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    else
      puts response.value
      exit
    end
  rescue => e
    puts [e.class, e].join("\n")
    exit
  end
end

def organization_url
  URI.parse("#{MACKEREL_API_LOCATION}/org")
end

def hosts_url
  URI.parse("#{MACKEREL_API_LOCATION}/hosts")
end

def metric_names_url(host_id)
  URI.parse("#{MACKEREL_API_LOCATION}/hosts/#{host_id}/metric-names")
end

def metric_url(host_id, metric_name, first_day, last_day)
  URI.parse("#{MACKEREL_API_LOCATION}/hosts/#{host_id}/metrics\?name\=#{metric_name}\&from\=#{first_day}\&to\=#{last_day}")
end

print 'Api Key: '
api = API.new(STDIN.gets.chomp)

organization = api.get_json(organization_url)
puts "\nOrganization:"
puts "  #{organization['name']}"

hosts = api.get_json(hosts_url)['hosts']
puts "\nHosts:"
hosts.map! {|host| { name: host['name'], id: host['id'] } }
hosts.each { |host| puts "  #{host[:name]}" }

print "\nHost name: "
host_name = STDIN.gets.chomp
host_id = hosts.find { |host| host[:name] == host_name }[:id]
metrics = api.get_json(metric_names_url(host_id))
puts "\nMetrics:"
metrics['names'].each {|metric| puts "  #{metric}" }

print "\nMetric Name: "
metric_name = STDIN.gets.chomp
print 'First Day(YYYY-MM-DD): '
first_day = Time.parse(STDIN.gets.chomp).to_i
print 'Last Day(YYYY-MM-DD): '
last_day = Time.parse(STDIN.gets.chomp).to_i

url_for_metric = metric_url(host_id, metric_name, first_day, last_day)
metric_values = api.get_json(url_for_metric)
puts metric_values
