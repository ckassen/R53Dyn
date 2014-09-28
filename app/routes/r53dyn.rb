# r53dyn.rb

require 'sinatra/base'
require 'aws-sdk'

require 'aws'

module R53Dyn
  class Web < Sinatra::Base

    get '/update' do

      # check parameters

      # parameters
      # domain
      # ip
      # username
      # password


      print params

      #
      #Angabe	Bezeichnung für den Platzhalter
      #IPv4-Adresse	<ipaddr>
      #    Benutzername	<username>
      #    Kennwort	<pass>
      #    Domänenname	<domain>
      #    IPv6-Adresse	<ip6addr>

      zoneid = nil

      # load access keys from env variable
      r53 = AWS::Route53.new(
          :access_key_id => ENV['AWS_KEY'],
          :secret_access_key => ENV['AWS_SECRET'])

      # Scan hosted zones for our domain
      zoneid = R53Dyn::Aws.get_zoneid(r53.client, 'kassen.name.')

      print zoneid

      # Found the correct zone, update the ip record
      if zoneid != nil

        # Prepare the change record
        resp_data = R53Dyn::Aws.update_record(r53, zoneid, domain, ipaddr)
      end
    end
  end
end