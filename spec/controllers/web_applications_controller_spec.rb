require 'spec_helper'

describe WebApplicationsController do
  let(:web_app_owner) { FactoryGirl.create(:user, email: "erica@cfa.org") }
  let(:web_app)       { FactoryGirl.create(:web_application, name: "monkey",
                                           status_url: "http://www.example.com/status") }
  before do
    body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
    FakeWeb.register_uri(:get, "http://www.example.com/status", body: body_string)
    web_app.update_attributes(users: [web_app_owner])
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

  shared_examples "an action that restricts access to application managers" do
    it "successfully renders the page if the user can manage the app" do
      session[:email] = "erica@cfa.org"
      get action, params
      response.should be_success
    end

    it "redirects when the user is not logged in" do
      session[:email] = "someone.else@cfa.org"
      get action, params
      response.should be_redirect
    end
  end

  describe "#show" do
    let(:action)  { :show }
    let(:params)  { {"id" => web_app.name} }

    it_behaves_like "an action that requires login"

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
    let(:action) { :index }
    let(:params) { {} }

    it_behaves_like "an action that requires login"

    it "returns ok" do
      get action, params
      response.should be_success
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
    it_behaves_like "an action that restricts access to application managers"
  end

  describe "#create" do
    let(:current_user) { FactoryGirl.create(:user) }
    let(:params)       { {"web_application" => {"name" => "Test Web App",
                                                "status_url" => "http://www.example.com/status",
                                                "user" => {"ids" => [""]}}} }

    before do
      controller.stub(:current_user).and_return(current_user)
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, "http://www.example.com/status", body: body_string)
    end

    it "creates a web application belonging to the current user" do
      expect {
        post :create, params
      }.to change(current_user.web_applications, :count).by(1)
    end

    it "creates a web application belonging to more than one user" do
      another_user = FactoryGirl.create(:user)
      users_hash = {"web_application" => {"user" => {"ids" => ["", another_user.id.to_s]}}}
      post :create, params.deep_merge(users_hash)
      web_application = WebApplication.find_by_name("Test Web App")
      web_application.users.count.should == 2
    end

    it "redirects to the user's web applications index page" do
      post :create, params
      response.should be_redirect
    end

    it "renders the new page and shows a flash message when attributes are missing" do
      post :create, {"web_application" => {"name" => "Test Web App", "user" => {"ids" => [""]}}}
      response.should render_template(:new)
      flash.now[:alert].should_not be_nil
    end

    it "renders the new page and shows a flash message when the status url does not return a valid response" do
      FakeWeb.register_uri(:get, "http://www.example.com/status", :status => ["500", "Internal Server Error"])
      post :create, params
      response.should render_template(:new)
      flash.now[:alert].should_not be_nil
    end
  end

  describe "#update" do
    let(:current_user)    { FactoryGirl.create(:user) }
    let(:status_url)      { "http://www.example.com/status" }
    let(:web_application) { FactoryGirl.create(:web_application, status_url: status_url,
                                               name: "Test Application") }
    let(:params)          { {"web_application" => {"name" => "Meow Test Web App", 
                                                   "status_url" => status_url,
                                                   "user" => {"ids" => [""]}},
                                                   "id" => web_application.slug} }

    before do
      controller.stub(:current_user).and_return(current_user)
      body_string = "{\"status\":\"ok\",\"updated\":1379539549,\"dependencies\":null,\"resources\":null}"
      FakeWeb.register_uri(:get, status_url, body: body_string)
      web_application.update_attributes(users: [current_user])
    end

    it "updates a web application belonging to the current user" do
      put :update, params
      web_application.reload.name.should == "Meow Test Web App"
    end

    it "updates a web application to have more than one user" do
      another_user = FactoryGirl.create(:user)
      users_hash = {"web_application" => {"user" => {"ids" => ["", another_user.id.to_s]}}}
      put :update, params.deep_merge(users_hash)
      web_application.reload.users.should == [current_user, another_user]
    end

    it "does not re-assign a user to the web application" do
      another_user = FactoryGirl.create(:user)
      web_application.users << another_user
      users_hash = {"web_application" => {"user" => {"ids" => ["", another_user.id.to_s]}}}
      put :update, params.deep_merge(users_hash)
      web_application.reload.users.should == [current_user, another_user]
    end

    it "redirects to the user's web applications index page" do
      put :update, params
      response.should be_redirect
    end

    it "renders the edit page and shows a flash message when attributes are invalid" do
      put :update, {"web_application" => {"name" => "", "user" => {"ids" => [""]}}, "id" => web_application.slug}
      response.should render_template(:edit)
      flash.now[:alert].should_not be_nil
    end

    it "renders the edit page and shows a flash message when the status url does not return a valid response" do
      FakeWeb.register_uri(:get, "http://www.example.com/status", :status => ["500", "Internal Server Error"])
      put :update, params
      response.should render_template(:edit)
      flash.now[:alert].should_not be_nil
    end
  end

  describe "#delete" do
    it "destroys the web application" do
      delete :destroy, {"id" => web_app.slug}
      WebApplication.find_by_id(web_app.id).should be_nil
    end
  end
end
