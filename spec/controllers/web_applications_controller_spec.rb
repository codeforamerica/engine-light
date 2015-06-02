require 'spec_helper'

describe WebApplicationsController do
  let(:web_app)       { FactoryGirl.create(:web_application_with_user, name: "monkey",
                                           status_url: "http://www.example.com/status") }
  let(:web_app_owner) { web_app.users.first }

  before do
    body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
    FakeWeb.register_uri(:get, "http://www.example.com/status", body: body_string)
    web_app_owner.update_attributes(email: "erica@cfa.org")
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

  shared_examples "an action that restricts access to application managers and admins" do
    it "successfully renders the page if the user can manage the app" do
      session[:email] = "erica@cfa.org"
      get action, params
      response.should be_success
    end

    it "successfully renders the page if the user is an admin" do
      FactoryGirl.create(:user, email: "pui@cfa.org", role: "admin")
      session[:email] = "pui@cfa.org"
      get action, params
      response.should be_success
    end

    it "redirects when the currently logged in user does not own the application" do
      session[:email] = "someone.else@cfa.org"
      get action, params
      response.should be_redirect
    end
  end

  describe "#show" do
    let(:action)  { :show }
    let(:params)  { {"id" => web_app.name} }

    it_behaves_like "an action that requires login"
    it_behaves_like "an action that restricts access to application managers and admins"

    before do
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.example.com/status", body: body_string)
    end

    it "returns ok with a valid application" do
      get action, params
      response.should be_success
    end

    it "throws an exception when passed a non-existent application" do
      expect{
        get action, id: "pretend_monkey"
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "#index" do
    let(:action)        { :index }
    let(:params)        { {} }
    let(:other_web_app) { FactoryGirl.create(:web_application_with_user,
                                             status_url: "http://www.example.com/status") }

    it_behaves_like "an action that requires login"

    it "returns ok" do
      get action, params
      response.should be_success
    end

    it "returns apps belonging to the user if they are an app manager" do
      get action, params
      assigns(:web_applications).should == [web_app]
    end

    it "returns all apps when the user is an admin" do
      current_user = FactoryGirl.create(:user, role: "admin")
      controller.stub(:current_user).and_return(current_user)
      get action, params
      assigns(:web_applications).should == [web_app, other_web_app]
    end
  end

  describe "#new" do
    let(:action) { :new }
    let(:params) { {"id" => web_app.slug} }

    it_behaves_like "an action that requires login"
  end

  describe "#edit" do
    let(:action) { :edit }
    let(:params)  { {"id" => web_app.slug} }

    it_behaves_like "an action that requires login"
    it_behaves_like "an action that restricts access to application managers and admins"
  end

  describe "#create" do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:params)       { {"web_application" => {"name" => "Test Web App",
                                                "status_url" => "http://www.example.com/status",
                                                "slack_channels" => "foo,",
                                                "user" => {"emails" => [current_user.email]}}} }
    before { controller.stub(:current_user).and_return(current_user) }

    it "creates a web application belonging to the current user" do
      expect {
        post :create, params
      }.to change(current_user.web_applications, :count).by(1)
    end

    it "creates a web application belonging to more than one user" do
      another_user = FactoryGirl.create(:user)
      users_hash = {"web_application" => {"user" => {"emails" => [current_user.email, another_user.email]}}}
      post :create, params.deep_merge(users_hash)
      web_application = WebApplication.find_by_name("Test Web App")
      web_application.users.count.should == 2
    end

    it "redirects to the user's web applications index page" do
      post :create, params
      response.should be_redirect
    end

    it "renders the new page when no users are added to the app" do
      status_url = "http://www.example.com/status"
      post :create, {"web_application" => {"name" => "Test Web App", "status_url" => status_url,
                                           "user" => {"emails" => [""]}, "slack_channels" => "foo,"}}
      response.should render_template(:new)
    end

    it "renders the new page when attributes are missing" do
      post :create, {"web_application" => {"name" => "Test Web App", "user" => {"emails" => [""]}}}
      response.should render_template(:new)
    end

    it "renders the new page when the status url does not return a valid response" do
      FakeWeb.register_uri(:get, "http://www.example.com/status", :status => ["500", "Internal Server Error"])
      post :create, params
      response.should render_template(:new)
    end

    it "fixes slack channel names to autoinclude hashes" do
      post :create, params
      WebApplication.find_by_name("Test Web App").slack_channels.should == ["#foo"]
    end
  end

  describe "#update" do
    let(:status_url)      { "http://www.example.com/status" }
    let(:new_status_url)  { "http://www.secondexample.com/status" }
    let(:web_application) { FactoryGirl.create(:web_application_with_user, status_url: status_url,
                                               name: "Test Application") }
    let(:current_user)    { web_application.users.first }
    let(:params)          { {"web_application" => {"name" => "Meow Test Web App",
                                                   "status_url" => new_status_url,
                                                   "slack_channels" => "foo,",
                                                   "user" => {"emails" => [current_user.email]}},
                                                   "id" => web_application.slug} }

    before do
      controller.stub(:current_user).and_return(current_user)
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, new_status_url, body: body_string)
    end

    it "updates a web application belonging to the current user" do
      put :update, params
      web_application.reload.name.should == "Meow Test Web App"
    end

    it "updates a web application to have more than one user" do
      another_user = FactoryGirl.create(:user)
      users_hash = {"web_application" => {"user" => {"emails" => [current_user.email, another_user.email]}}}
      put :update, params.deep_merge(users_hash)
      web_application.reload.users.should == [current_user, another_user]
    end

    it "updates a web application to have more than one channel" do
      more_slack = {"web_application" => {"slack_channels" => "foo,bar"}}
      put :update, params.deep_merge(more_slack)
      web_application.reload.slack_channels.should == ["#foo", "#bar"]
    end

    it "does not re-assign a user to the web application" do
      another_user = FactoryGirl.create(:user)
      web_application.users << another_user
      users_hash = {"web_application" => {"user" => {"emails" => [current_user.email, another_user.email]}}}
      put :update, params.deep_merge(users_hash)
      web_application.reload.users.should == [current_user, another_user]
    end

    it "redirects to the user's web applications index page" do
      put :update, params
      response.should be_redirect
    end

    it "renders the edit page when attributes are invalid" do
      put :update, {"web_application" => {"name" => "", "user" => {"emails" => [""]}}, "id" => web_application.slug}
      response.should render_template(:edit)
    end

    it "renders the edit page when the status url does not return a valid response" do
      FakeWeb.register_uri(:get, new_status_url, :status => ["500", "Internal Server Error"])
      put :update, params
      response.should render_template(:edit)
    end
  end

  describe "#delete" do
    it "destroys the web application" do
      delete :destroy, {"id" => web_app.slug}
      WebApplication.find_by_id(web_app.id).should be_nil
    end
  end
end
