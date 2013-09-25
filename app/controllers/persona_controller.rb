class PersonaController < ApplicationController
  include Requester

  def login
    assertion = params["assertion"]
    email = get_identity(assertion)
    if email.present?
      session[:email] = email
      User.find_or_create_by(email: email)
    end
    if request.xhr?
      if check_for_cfa_email(email)
        render json: {location: web_applications_url}
      else
        render json: {}, status: :unauthorized
      end
    end
  end

  def logout
    session[:email] = nil
     if request.xhr?
      render json: {location: root_url}
    end
  end

  def get_identity(assertion)
    uri = "https://verifier.login.persona.org/verify"
    request_params = {assertion: assertion, audience: request.url}
    response = post(uri, request_params)
    email = response.try(:[], "email")
  end

  def check_for_cfa_email(email)
    email =~ /@(cfa|codeforamerica)\.org$/
  end
end