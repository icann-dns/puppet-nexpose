require "base64"
require "json"
require 'net/http'

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
filter = {
  field: 'host-name',
  operator: 'is',
  value: 'lax.manager.dns.icann.org',
}
req.body = {filters: [filter], match: 'all'}.to_json
uri = URI("https://iad.nexpose.dns.icann.org/api/3/sites?view=detail&size=500")
req = Net::HTTP::Get.new(uri)
req['Accept'] = 'application/json'
req['Content-Type'] = 'application/json'
req.basic_auth(@conf['user'], @conf['password'])
res = Net::HTTP.start(
  uri.hostname,
  uri.port,
  use_ssl: true,
  verify_mode: OpenSSL::SSL::VERIFY_NONE
) do |http|
  http.request(req)
end
result = JSON.parse(res.body)
puts result


