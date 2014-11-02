# update.rb

require 'sinatra/base'
require 'ipaddr'

require 'r53dyn/aws'

module R53Dyn
  module Routes
    class Update < Sinatra::Base

      def initialize(app = nil, dnslib = R53Dyn::Aws.new)
        super(app)
        @dnslib = dnslib
      end

      get '/update' do
        # parameters
        # domain
        # ip
        # username
        # password
        domain = params[:domain] || nil
        ipaddr = params[:ip] || nil

        username = params[:user] || nil
        password = params[:pass] || nil

        if domain.nil? || ipaddr.nil?
          error 500, 'Invalid parameters provided'
        end

        if username.nil? || password.nil?
          error 401, 'Authentication failed'
        else
          if ENV['R53DYN_USER'] != username || ENV['R53DYN_PASS'] != password
            error 401, 'Authentication failed'
          end
        end

        # check domain and ip value
        # domain must be a valid domain, better hostname validation required
        if (split = domain.split('.')).length == 3
          domainparts = split[1,2].join('.') + '.'
        else
          error 500, 'Domain must include a hostname'
        end

        begin
          IPAddr.new ipaddr
        rescue
          error 500, 'Invalid IP address'
        end

        # Scan hosted zones for our domain
        zoneid = @dnslib.get_zoneid(domainparts)

        # Found the correct zone, update the ip record
        if zoneid != nil

          # Prepare the change record
          resp_data = @dnslib.update_record(zoneid, domain, ipaddr)

          if resp_data
            #uri = 'http://%s' % domain
            #@response.headers['Location'] = uri
            "good %s\n" % ipaddr
          else
            error 500, 'Updating hostname failed'
          end
        else
          error 500, 'Updating hostname failed'
        end
      end
    end
  end
end