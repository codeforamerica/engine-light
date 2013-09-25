require 'spec_helper'

describe WebApplicationsController do
  before do 
    FactoryGirl.create(:user, email: "erica@cfa.org") 
    session[:email] = "erica@cfa.org"
  end

  shared_examples "an action that requires login" do
    it "successfully renders the page if the user is logged in" do
      session[:email] = "erica@cfa.org"
      get action, params
      response.should be_success
    end

    it "redirects when the user is not logged in" do
      session[:email] = nil
      get action, params
      response.should be_redirect
    end
  end

  describe "#show" do
    let(:action)  { :show }
    let(:web_app) { FactoryGirl.create(:web_application, name: "monkey") }
    let(:params)  { {id: web_app.name} }
 
    it_behaves_like "an action that requires login"

    before do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.codeforamerica.org/.well-known/status", body: body_string)
      session[:email] = "erica@cfa.org"
    end

    it "returns ok with a valid application" do
      get action, id: web_app.name
      response.should be_success
    end

    it "throws an exception when passed a non-existent application" do
      expect{
        get action, id: "pretend_monkey"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#index" do
    let(:action) { :index }
    let(:params)  { {} }

    it_behaves_like "an action that requires login"

    it "returns ok" do
      get action
      response.should be_success
    end
  end

  describe "#create" do
    let(:current_user) { FactoryGirl.create(:user) }
    before             {controller.stub(:current_user).and_return(current_user) }

    it "creates a web application belonging to the current user" do
      expect {
        post :create, {"web_application" => {"name" => "Test Web App", "status_url" => "http://www.example.com"},
                       "user_id" => current_user.id}
      }.to change(WebApplication, :count).by(1)
    end

    it "redirects to the user's web applications index page" do
      post :create, {"web_application" => {"name" => "Test Web App", "status_url" => "http://www.example.com"},
                     "user_id" => current_user.id}
      response.should be_redirect
    end

    it "renders the new page and shows a flash message when attributes are missing" do
      post :create, {"web_application" => {"name" => "Test Web App"}, "user_id" => current_user.id}
      response.should render_template(:new)
      flash.now[:alert].should_not be_nil
    end

    it "raises if a user other than the current user tries to create a web app" do
      user = FactoryGirl.create(:user)
      expect {
        post :create, {"web_application" => {"name" => "Test Web App", "status_url" => "http://www.example.com"},
                       "user_id" => user.id}
      }.to raise_error
    end
  end

  describe "#update" do
    let(:current_user)    { FactoryGirl.create(:user) }
    let(:web_application) { FactoryGirl.create(:web_application, user: current_user) }
    before                {controller.stub(:current_user).and_return(current_user) }

    it "updates a web application belonging to the current user" do
      put :update, {"web_application" => {"name" => "Meow Test Web App", "status_url" => "http://www.example.com"},
                      "user_id" => current_user.id, "id" => web_application.slug}
      web_application.reload.name.should == "Meow Test Web App"
    end

    it "redirects to the user's web applications index page" do
      put :update, {"web_application" => {"name" => "Test Web App", "status_url" => "http://www.example.com"},
                    "user_id" => current_user.id, "id" => web_application.slug}
      response.should be_redirect
    end

    it "renders the new page and shows a flash message when attributes are invalid" do
      put :update, {"web_application" => {"name" => ""}, "user_id" => current_user.id, "id" => web_application.slug}
      response.should render_template(:edit)
      flash.now[:alert].should_not be_nil
    end

    it "raises if a user other than the current user tries to update a web app" do
      user = FactoryGirl.create(:user)
      expect {
      put :update, {"web_application" => {"name" => "Test Web App", "status_url" => "http://www.example.com"},
                    "user_id" => user.id, "id" => web_application.slug}
      x}.to raise_error
    end
  end
end
