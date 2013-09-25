# User
user = User.create(email: "erica@codeforamerica.org")

# Web Application
name = "Code for America Website"
status_url = "http://staging.codeforamerica.org/.well-known/status"
WebApplication.create(name: name, status_url: status_url, user: user)