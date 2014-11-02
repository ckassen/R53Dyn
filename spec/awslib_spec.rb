#
require 'r53dyn/aws'

describe "R53Dyn AWS librarie" do

  before :each do
    @client = double("AWS::Route53")

    @aws = R53Dyn::Aws.new(@client)
  end

  describe "when fetching the zoneid" do
    it "should return the zoneid" do
      allow(@client).to receive(:list_hosted_zones){ {:hosted_zones => [{:name => 'domain.', :id => '12345'}]} }

      zoneid = @aws.get_zoneid('domain.')
      expect(zoneid).to eq('12345')
    end
  end

  describe "when preparing the record change" do
    it "should return the change record hash" do
      z = @aws.prepare_record('127.0.0.1', 'dyn.example.com.')

      expect(z).to eq({:action => 'UPSERT',
          :resource_record_set => {:name => 'dyn.example.com.', :type => 'A', :ttl => 180,
              :resource_records => [{:value => '127.0.0.1'}]}})
    end
  end
end