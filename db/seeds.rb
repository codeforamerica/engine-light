# User
user1 = User.create(email: "erica@codeforamerica.org", role: "admin")
user2 = User.create(email: "pui@codeforamerica.org")

# Web Application
name = "Code for America Website"
status_url = "http://staging.codeforamerica.org/.well-known/status"
WebApplication.create(name: name, status_url: status_url, current_status: "ok", users: [user1])
name = "Code for America Website Copy"
WebApplication.create(name: name, status_url: status_url, current_status: "ok", users: [user2])

