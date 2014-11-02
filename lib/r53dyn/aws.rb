#
require 'aws-sdk'

module R53Dyn
  class Aws

    def initialize(client = nil)

      unless client
        # do aws init here somehow
        options ={
            :access_key_id => ENV['AWS_KEY'],
            :secret_access_key => ENV['AWS_SECRET'],
        }

        r53 = AWS::Route53.new options
        @client = r53.client
      else
        @client = client
      end

    end

    def get_zoneid(domain)
      zoneid = nil

      if domain.nil?
        raise R53Dyn::Exception.new('No domain provided')
      end

      # domain must have a dot at the end
      if domain[-1, 1] != '.'
        return nil
      end

      resp = @client.list_hosted_zones

      unless resp[:hosted_zones].nil?
        resp[:hosted_zones].each do |zone|
          if zone[:name] == domain
            zoneid = zone[:id]
          end
        end
      end

      zoneid
    end

    def update_record(zoneid, record, ipaddr)

      unless zoneid || record || ipaddr
        return false
      end

      begin
        change = prepare_record(ipaddr, record)

        # Send the change record to the AWS api
        change_resp = @client.client.change_resource_record_sets({
                                                                  :hosted_zone_id => zoneid,
                                                                  :change_batch => {
                                                                      :changes => [change]
                                                                  }
                                                              })

        change_resp.successful?
      rescue
        false
      end
    end

    def prepare_record(ipaddr, record)
      {
          :action => 'UPSERT',
          :resource_record_set => {
              :name => record,
              :type => 'A',
              :ttl => 180,
              :resource_records => [{:value => ipaddr}]
          }}
    end
  end
end