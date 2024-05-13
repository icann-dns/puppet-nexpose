require "base64"
require "json"
require 'net/http'

# Nexpose class
class Puppet::Provider::Nexpose < Puppet::Provider
  def config
    @api_file = '/opt/rapid7/nexpose/nsc/conf/api.conf'
    @conf     = {
      'user'     => 'nxadmin',
      'password' => 'nxpassword',
      'server'   => 'localhost',
      'port'     => 443,
    }
    if File.file?(@api_file)
      File.open(@api_file, 'r') do |f|
        f.each_line do |line|
          tokens = line.strip.split('=')
          @conf[tokens[0]] = tokens[1]
        end
      end
    end
    @conf
  end

  def request(path, post = false, body = nil, size = 500, view = 'summary')
    uri = URI("https://#{config['server']}:#{config['port']}/api/3/#{path}")
    uri.query = URI.encode_www_form({
      view: view,
      size: size  # currently we have < 400 but we will need paging at some point
    })
    req = if post
            Net::HTTP::Post.new(uri)
          else
            Net::HTTP::Get.new(uri)
          end
    req['Accept'] = 'application/json'
    req['Content-Type'] = 'application/json'
    req.basic_auth(config['user'], config['password'])
    req.body = body
    res = Net::HTTP.start(
      uri.hostname,
      uri.port,
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    ) do |http|
      http.request(req)
    end
    JSON.parse(res)
  end

  def sites
    request('sites', view: 'detail')['resources'].map do |resource|
      {
        id: resource['id'],
        name: resource['name'],
        desciption: resource['desciption'],
        scan_template: resource['scanTemplate']
      }
    end
  end

  def assets
    request('assets')
  end


end
