require 'minitest/spec'
require 'minitest/autorun'

require 'r53dyn/aws'

describe 'Aws' do

  before :each do
    option = {:access_key_id => ENV['AWS_KEY'],
    :secret_access_key => ENV['AWS_SECRET']}

    AWS.stub!

    @aws = R53Dyn::Aws.new(option)

    #@aws.r53 = Minitest::Mock()
  end

  it 'should get the zoneid' do
    #z = @aws.get_zoneid('domain.')
    #true.must_be == false
  end

  it 'should prepare the record change' do
    z = @aws.prepare_record('127.0.0.1', 'dyn.example.com.')
    #z.must_be_instance_of Hash
    z.must_be := , {:action => 'UPSERT',
        :resource_record_set => {:name => 'dyn.example.com.', :type => 'A', :ttl => 180,
            :resource_records => [{:value => '127.0.0.1'}]}}
  end
end