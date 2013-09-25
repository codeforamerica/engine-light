# User
user1 = User.create(email: "erica@codeforamerica.org")
user2 = User.create(email: "pui@codeforamerica.org")

# Web Application
name = "Code for America Website"
status_url = "http://staging.codeforamerica.org/.well-known/status"
WebApplication.create(name: name, status_url: status_url, user: user1)
name = "Code for America Website Copy"
WebApplication.create(name: name, status_url: status_url, user: user2)

