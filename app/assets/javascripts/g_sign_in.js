function onSignIn(googleUser) {
  var profile = googleUser.getBasicProfile();
  var dataString = 'email=' + profile.getEmail() + '&name=' + profile.getName();
  $.ajax({
    type: "POST",
    url: "/users/new_from_g_sign_in",
    data: dataString,
    dataType: "script"
  });
}
