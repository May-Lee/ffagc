# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def account_activation
    artist = default_artist
    if artist.activation_token.nil?
      artist.activation_token = ApplicationController.new_token
    end

    UserMailer.account_activation('artists', artist)
  end

  def password_reset
    artist = default_artist
    if artist.reset_token.nil?
      artist.reset_token = ApplicationController.new_token
    end

    UserMailer.password_reset('artists', artist)
  end

  def voter_verified
    voter = default_voter
    UserMailer.voter_verified(voter, Rails.configuration.event_year)
  end

  def grant_funded
    grant_submission = GrantSubmission
      .where(funding_decision: true)
      .where("granted_funding_dollars > 0")
      .first || FactoryGirl.create(:grant_submission)
    artist = Artist.where(id: grant_submission.artist).first || FactoryGirl.create(:artist)
    grant = Grant.where(id: grant_submission.grant).first || FactoryGirl.create(:grant)
    UserMailer.grant_funded(grant_submission, artist, grant, Rails.configuration.event_year)
  end

  def grant_not_funded
    grant_submission = GrantSubmission
      .where(funding_decision: true)
      .where("granted_funding_dollars == 0")
      .first || FactoryGirl.create(:grant_submission)
    artist ||= Artist.where(id: grant_submission.artist).take || FactoryGirl.create(:artist)
    grant ||= Grant.where(id: grant_submission.grant).take || FactoryGirl.create(:grant)
    UserMailer.grant_not_funded(grant_submission, artist, grant, Rails.configuration.event_year)
  end

  def notify_questions
    grant_submission = GrantSubmission.first || FactoryGirl.create(:grant_submission)
    artist ||= Artist.where(id: grant_submission.artist).take || FactoryGirl.create(:artist)
    grant ||= Grant.where(id: grant_submission.grant).take || FactoryGirl.create(:grant)
    UserMailer.notify_questions(grant_submission, artist, grant, Rails.configuration.event_year)
  end

  private

  def default_artist
    Artist.first || FactoryGirl.create(:artist, :activated)
  end

  def default_voter
    Voter.first || FactoryGirl.create(:voter, :activated)
  end

  def default_grant
    Grant.first || FactoryGirl.create(:grant)
  end
end
