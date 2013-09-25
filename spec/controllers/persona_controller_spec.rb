require 'spec_helper'

describe PersonaController do
  describe "#login" do
    context "with a cfa email address" do
      before do
        controller.stub(:get_identity).and_return("erica@cfa.org")
        xhr :post, :login
      end

      it "sets a session variable when an identity is found" do
        session[:email].should == "erica@cfa.org"
      end

      it "renders json with a redirect location" do
        response.body.should == {location: web_applications_url}.to_json
      end
    end

    context "with a non-cfa address" do
      it "responds with an unauthorized status" do
        controller.stub(:get_identity).and_return("erica@hellokitty.com")
        xhr :post, :login
        response.code.should == "401"
      end
    end
  end

  describe "#logout" do
    before do
      session[:email] = "erica@cfa.org"
      xhr :post, :logout
    end    

    it "sets the session variable to nil" do
      session[:email].should be_nil      
    end
  
    it "renders json with a redirect location" do
      response.body.should == {location: root_url}.to_json      
    end
  end

  describe "#get_identity" do
    it "returns an email address when mozilla confirms the identity assertion" do
      response_body = <<-eos 
              {
              "status": "okay",
              "email": "erica@cfa.org",
              "audience": "https://engine-light.cfa.org",
              "expires": 1308859352261,
              "issuer": "cfa.org"
             }
             eos
      FakeWeb.register_uri(:post, "https://verifier.login.persona.org/verify", body: response_body)
      assertion = "stuff"
      controller.get_identity(assertion).should == "erica@cfa.org"
    end

    it "returns nil when mozilla rejects the identity assertion" do
      response_body = "{}"
      FakeWeb.register_uri(:post, "https://verifier.login.persona.org/verify", body: response_body)
      assertion = "stuff"
      controller.get_identity(assertion).should be_nil      
    end

    it "raises if the post does not return ok" do
      FakeWeb.register_uri(:post, "https://verifier.login.persona.org/verify", :status => ["500", "Internal Server Error"])
      assertion = "stuff"
      expect { controller.get_identity(assertion) }.to raise_error
    end
  end
end