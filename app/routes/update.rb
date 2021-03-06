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

      def checkAuthentication(password, username)
        if username.nil? || password.nil?
          error 401, 'Authentication failed'
        else
          if ENV['R53DYN_USER'] != username || ENV['R53DYN_PASS'] != password
            error 401, 'Authentication failed'
          end
        end
      end

      def checkHostname(domain, ipaddr)
        begin
          IPAddr.new ipaddr
        rescue
          error 500, 'Invalid IP address'
        end

        if (split = domain.split('.')).length == 3
          domainparts = split[1, 2].join('.') + '.'
        else
          error 500, 'Domain must include a hostname'
        end

        domainparts
      end

      get '/update' do

        domain = params[:domain] || nil
        ipaddr = params[:ip] || nil

        username = params[:user] || nil
        password = params[:pass] || nil

        if domain.nil? || ipaddr.nil?
          error 500, 'Invalid parameters provided'
        end

        self.checkAuthentication(password, username)

        # check domain and ip value
        # domain must be a valid domain, better hostname validation required
        domainparts = self.checkHostname(domain, ipaddr)

        # Scan hosted zones for our domain
        zoneid = @dnslib.get_zoneid(domainparts)

        # Found the correct zone, update the ip record
        if zoneid != nil

          # Prepare the change record
          resp_data = @dnslib.update_record(zoneid, domain, ipaddr)

          if resp_data
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