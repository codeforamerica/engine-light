class WebApplicationMailer < ActionMailer::Base
  default from: "alerts@codeforamerica.org"
  include Requester

  def outage_notification(web_application)
    user_emails = web_application.users.map(&:email)
    @web_application = web_application
    mail(to: user_emails, subject: "#{web_application.name} is down")
    link = url_for(host: ENV["HOST_NAME"], controller: "web_applications", action: "show", id: @web_application.slug)
    if @web_application.slack_channels?
      @web_application.slack_channels.each do |channel|
        post_to_slack(channel, "The application #{@web_application.name} is down. Status: #{@web_application.current_status}.\nFor more inforation, visit <#{link}|Engine Light>.")
      end
    end
  end

  def recovery_notification(web_application)
    user_emails = web_application.users.map(&:email)
    @web_application = web_application
    mail(to: user_emails, subject: "#{web_application.name} has recovered")
    link = url_for(host: ENV["HOST_NAME"], controller: "web_applications", action: "show", id: @web_application.slug)
    if @web_application.slack_channels?
      @web_application.slack_channels.each do |channel|
        begin
          post_to_slack(channel, "Your application #{@web_application.name} has recovered!\nFor more inforation, visit <#{link}|Engine Light>.")
        rescue
        end
      end
    end
  end

  # private
  def post_to_slack(channel, msg)
    uri = Rails.configuration.slack_webhook_url
    request_uri = URI.parse(uri)

    http = Net::HTTP.new(request_uri.host, request_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    params = {channel: channel, text: msg, username: 'engine-light-bot', icon_emoji: ':exclamation:'}

    request = Net::HTTP::Post.new(request_uri.path)
    request.add_field('Content-Type', 'application/json')
    request.body = params.to_json
    response = http.request(request)
    puts response.body
  end
end
