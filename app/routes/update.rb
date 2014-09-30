# r53dyn.rb

require 'sinatra/base'
require 'aws-sdk'

require 'ipaddr'

require 'lib/r53dyn/aws'

module R53Dyn
  module Routes
    class Update < Sinatra::Base

      get '/update' do
        # parameters
        # domain
        # ip
        # username
        # password
        domain = params[:domain] || nil
        ipaddr = params[:ip] || nil

        username = params[:username] || nil
        password = params[:password] || nil

        if domain.nil? || ipaddr.nil?
          error 403, 'Invalid parameters provided'
        end

        #if username.nil? || password.nil?
        #  error 401, 'Authentication failed'
        #end

        # TODO
        # check domain and ip value
        # domain must be a valid domain, better hostname validation required

        domainparts = domain.split('.')[1,2].join('.') + '.'

        begin
          IPAddr.new ipaddr
        rescue
          error 500, 'Invalid IP address'
        end

        # Scan hosted zones for our domain
        dnslib = R53Dyn::Aws.new(:access_key_id => ENV['AWS_KEY'],
                                 :secret_access_key => ENV['AWS_SECRET'])

        zoneid = dnslib.get_zoneid(domainparts)

        # Found the correct zone, update the ip record
        if zoneid != nil

          # Prepare the change record
          resp_data = dnslib.update_record(zoneid, domain, ipaddr)

          if resp_data
            uri = 'http://%s' % domain
            @response.headers[:location] = uri
          else
            error 500, 'Updating hostname failed'
          end
        end
      end
    end
  end
end