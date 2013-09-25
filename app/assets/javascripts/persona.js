navigator.id.watch({
  loggedInUser: currentUser,
  onlogin: function(assertion) {
    // A user has logged in! Here you need to:
    // 1. Send the assertion to your backend for verification and to create a session.
    // 2. Update your UI.
    $.ajax({ /* <-- This example uses jQuery, but you can use whatever you'd like */
      type: 'POST',
      url: '/persona/login',
      data: {assertion: assertion},
      success: function(response_data) {
        if (response_data.location) {
          window.location.href = response_data.location;
        }
      },
      error: function(xhr, status, err) {
        navigator.id.logout();
        alert("Login failure: " + err);
      }
    });
  },
  onlogout: function() {
    // A user has logged out! Here you need to:
    // Tear down the user's session by redirecting the user or making a call to your backend.
    // Also, make sure loggedInUser will get set to null on the next page load.
    // (That's a literal JavaScript null. Not false, 0, or undefined. null.)
    $.ajax({
      type: 'POST',
      url: '/persona/logout',
      success: function(response_data) {
        if (response_data.location) {
          window.location.href = response_data.location;
        }
      },
      error: function(xhr, status, err) { alert("Logout failure: " + err); }
    });
  }
});
