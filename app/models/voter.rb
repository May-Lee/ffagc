class Voter < ActiveRecord::Base
  include Activatable
  include PasswordReset

  has_secure_password

  has_many :grants_voters
  has_many :grants, through: :grants_voters
  has_many :votes
  has_one :voter_survey, inverse_of: :voter
  has_many :voter_submission_assignments
  has_many :grant_submissions, through: :voter_submission_assignments

  accepts_nested_attributes_for :voter_survey

  validates :name, presence: true, length: { minimum: 4 }
  validates :email, presence: true
  validates :password, length: { minimum: 4 }, on: :create

  validates_confirmation_of :password, on: :create

  scope :activated, -> { where(activated: true) }
  scope :verified, -> { activated.where(verified: true) }

  def as_email_recipient
    "#{self.name} <#{self.email}>"
  end

  # Return the number of submissions this voter has been assigned for a specific
  # grant type.
  def assignments_per_grant(grant_id)
    VoterSubmissionAssignment.joins(:voter, :grant_submission)
        .where('voters.id' => id)
        .where('grant_submissions.grant_id' => grant_id)
        .count
  end
end
