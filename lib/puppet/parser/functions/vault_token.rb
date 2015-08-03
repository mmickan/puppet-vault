module Puppet::Parser::Functions
  newfunction(:vault_token, :type => :rvalue, :doc => <<-EOS
Logs in to Vault using the App ID auth backend and returns a token if
successful, or false if unsuccessful.

Expected arguments are:
  app_id:  the application ID to log in with
  user_id: the user ID to log in with
EOS
  ) do |arguments|

    require 'net/http'
    require 'net/https'
    require 'json'

    raise(Puppet::ParseError, "vault_token(): Wrong number of arguments " +
      "given (#{arguments.size} for 2)") if arguments.size != 2

    app_id = arguments[0]
    user_id = arguments[1]

    unless app_id.is_a?(String)
      raise(Puppet::ParseError, "vault_token(): app_id must be a string")
    end
    unless user_id.is_a?(String)
      raise(Puppet::ParseError, "vault_token(): user_id must be a string")
    end

    begin
      vault = Net::HTTP.new('127.0.0.1', '8200')
      vault.read_timeout = 10
      vault.open_timeout = 10
      vault.use_ssl = true

      httpreq = Net::HTTP::Get.new('/v1/auth/app-id/login')
      httpres = vault.request(httpreq)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError, Errno::ECONNREFUSED => e
      return nil
    end

    if httpres.kind_of?(Net::HTTPSuccess)
      begin
        records = JSON.parse(httpres.body)
      rescue
        return nil
      end
      if records.has_key?('auth')
        if records['auth'].has_key?('client_token')
          return records['auth']['client_token']
        end
      end
    end

    return nil
  end
end

# vim: set ts=2 sw=2 et :
