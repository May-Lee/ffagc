class Sessions::VotersController < Sessions::BaseController

  alias_method :resource_logged_in?, :voter_logged_in?

  def type_name
    'voters'
  end

  def session_key
    :voter_id
  end

  def resource_by_email(email)
    Voter.find_by_email(email)
  end

  def form_action_path
    sessions_voter_path
  end

  def after_create_path
    if !current_voter.activated?
      votes_path
    elsif !current_voter.verified?
      unverified_sessions_voter_path
    else
      votes_path
    end
  end
end
