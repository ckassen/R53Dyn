ENV['RACK_ENV'] = 'test'
ENV['R53DYN_USER'] = 'demo'
ENV['R53DYN_PASS'] = 'demo'

require 'rack/test'

require File.expand_path '../spec_helper.rb', __FILE__

describe "R53Dyn DNS Update" do

  let(:service) { double("R53Dyn::Aws") }
  let(:app) { R53Dyn::Routes::Update.new(@app, service) }

  context "when the dns entry is updated" do
    it "shows good ip" do

      expect(service).to receive(:get_zoneid).and_return("abcdef")
      expect(service).to receive(:update_record).and_return(true)

      get '/update?domain=www.example.com&ip=127.0.0.1&user=demo&pass=demo'
        expect(last_response).to be_ok
        expect(last_response.status).to eq(200)
        expect(last_response.body).to eq("good 127.0.0.1\n")
    end
  end

  context "when the backend service dns update fails" do
    it "returns error" do

      expect(service).to receive(:get_zoneid).and_return("abcdef")
      expect(service).to receive(:update_record).and_return(false)

      get '/update?domain=www.example.com&ip=127.0.0.1&user=demo&pass=demo'
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq(500)
    end
  end

  context "when the domain entry is invalid" do
    it "returns 500 error" do

      get '/update?domain=demo.com&ip=127.0.0.1&user=demo&pass=demo'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)
    end
  end

  context "when the domain entry is missing" do
    it "returns 500 error" do

      get '/update?ip=127.0.0.1&user=demo&pass=demo'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(500)
    end
  end

  context "when the user/password is invalid" do
    it "returns 401 error" do

      get '/update?domain=host.demo.com&ip=127.0.0.1&user=demo&pass=test'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq(401)
    end
  end

end