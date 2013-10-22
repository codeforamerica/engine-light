require 'spec_helper'

describe UsersController do

  let(:user)   { FactoryGirl.create(:user, email: "erica@cfa.org") }

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

  shared_examples "an action that only allows admins and users access their info" do
    it "successfully renders the page if the user accesses their info" do
      session[:email] = "erica@cfa.org"
      get action, params
      response.should be_success
    end

    it "redirects if the current user tries to edit a different user's settings" do
      FactoryGirl.create(:user, email: "someone.else@cfa.org")
      session[:email] = "someone.else@cfa.org"
      get action, params
      response.should be_redirect
    end
  end

  describe "#show" do
    let(:action) { :show }
    let(:params) { {"id" => user.id} }

    it_behaves_like "an action that requires login"
    it_behaves_like "an action that only allows admins and users access their info"
  end

  describe "#edit" do
    let(:action) { :edit }
    let(:params) { {"id" => user.id} }

    it_behaves_like "an action that requires login"
    it_behaves_like "an action that only allows admins and users access their info"
  end

  describe "#update" do
    before { controller.stub(:current_user).and_return(user) }

    it "updates settings belonging to the current user" do
      put :update, {"id" => user.id, "user" => {"name" => "Meow Meowser"}}
      user.reload.name.should == "Meow Meowser"
      flash[:notice].should_not be_nil
    end

   it "updates settings even when name is nil" do
      put :update, {"id" => user.id, "user" => {"name" => nil}}
      user.reload.name.should be_nil
      flash[:notice].should_not be_nil
    end
  end
end