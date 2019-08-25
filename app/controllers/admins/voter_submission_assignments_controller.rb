#
# Provides endpoints for an admin to assign GrantSubmissions to verified Voters
# and to delete destroy all VoterSubmissionAssignments
#
class Admins::VoterSubmissionAssignmentsController < ApplicationController
  load_and_authorize_resource

  # Distributes voter assignments fairly. Can handle newly-added Voters and
  # GrantSubmissions without changing existing assignments.
  #
  # Does NOT guarantee that a new Voter will get any assignments if all
  # GrantSubmissions already have enough Voters.
  #
  # Cleans any existing invalid VoterSubmissionAssignments.
  #
  # Goes through each unique GrantSubmission and assigns eligible voters to that
  # GrantSubmission choosing Voters with fewest VoterSubmissionAssignments for
  # that grant type first. Will not assign more than Grantsubmission#max_voters
  # Voters to a GrantSubmission.
  #
  # If a GrantSubmission needs more Voters but non are eligible nothing happens for
  # that GrantSubmission.
  #
  # Will not assign a Voter the same GrantSubmission more than once.
  def assign
    clean_assignments

    GrantSubmission.all.each do |grant_submission|
      # find voters not assigned this grant
      voters = grant_submission.grant.voters
        .includes(:voter_submission_assignments, :grant_submissions)
        .where(verified: true)

      # eligible_voters must not already be assigned to this grant_submission
      eligible_voters = voters.reject do |voter|
        voter.grant_submissions.include?(grant_submission)
      end

      # Sort by least number of voter_submission_assignments. The order for
      # voters with the same number of voter_submission_assignment is randomized.
      #
      # Take only as many as are required to give grant_submission the desired
      # number of voters.
      voters_to_assign = eligible_voters
        .shuffle
        .sort_by { |voter| voter.assignments_per_grant(grant_submission.grant_id) }
        .take(grant_submission.num_voters_to_assign)

      voters_to_assign.each do |voter|
        VoterSubmissionAssignment.create!(
          grant_submission: grant_submission,
          voter: voter
        )
      end
    end

    redirect_to admins_path
  end

  def destroy
    VoterSubmissionAssignment.destroy_all

    redirect_to admins_path
  end

  private

  # Goes through the voter assignments and delete extraneous entries.
  # Unverified voters keep their assignments because their values are
  # ignored, so they can be readded (which happens).
  def clean_assignments
    VoterSubmissionAssignment.find_each do |vsa|
      # Delete if the voter is gone
      if Voter.find_by_id(vsa.voter_id) == nil
        vsa.destroy
        next
      end
      # Delete if the submission is gone
      gs = GrantSubmission.find_by_id(vsa.grant_submission_id)
      if gs == nil
        vsa.destroy
        next
      end
      # Delete if the voter is not part of this grant any more
      if GrantsVoter.find_by(grant: gs.grant_id, voter: vsa.voter_id) == nil
        vsa.destroy
        next
      end
    end
  end
end
