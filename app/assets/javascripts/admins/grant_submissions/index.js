function toggle_all_fund_emails(event) {
  event.preventDefault();
  checkboxes = document.getElementsByName('fund_email_checkbox');
  var toggle_to = !checkboxes[0].checked;
  for(var i=0, n=checkboxes.length; i<n; i++) {
    checkboxes[i].checked = toggle_to;
  }
  return false;
}

function confirm_selected(event) {
  event.preventDefault();
  checkboxes = document.getElementsByName('fund_email_checkbox');
  var selected = [];
  for (var i=0, n=checkboxes.length; i<n; i++) {
    if (checkboxes[i].checked) {
      var id = checkboxes[i].id.split("-")[1];
      selected.push(id);
    }
  }
  if (selected.length == 0) {
    return false;
  }
  var send_email = document.getElementById('send_grant_fund_email_checkbox').checked;
  $.post("<%= escape_javascript(send_fund_emails_admins_grant_submissions_path) %>?ids=" + selected + "&send_email=" + send_email);
  return false;
}
