require 'aws-sdk'

module R53Dyn
  class Aws

    @r53 = nil

    def initialize(options = {})
      @r53 = AWS::Route53.new(options)
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

      resp = @r53.client.list_hosted_zones
      resp[:hosted_zones].each do |zone|
        if zone[:name] == domain
          zoneid = zone[:id]
        end
      end

      zoneid
    end

    def update_record(zoneid, record, ipaddr)

      unless zoneid || record || ipaddr
        return false
      end

      begin
        change = {
            :action => 'UPSERT',
            :resource_record_set => {
                :name => record,
                :type => 'A',
                :ttl => 180,
                :resource_records => [{:value => ipaddr}]
            }}

        # Send the change record to the AWS api
        change_resp = @r53.client.change_resource_record_sets({
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
  end
end