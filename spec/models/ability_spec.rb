describe Ability do
  subject(:ability) { Ability.new(user) }

  shared_examples 'can manage Admin unless Admin.exists?' do
    it { is_expected.to be_able_to(:manage, Admin) }

    context 'an Admin already exists' do
      let!(:admin) { FactoryBot.create(:admin) }

      it { is_expected.not_to be_able_to(:manage, Admin) }
    end
  end

  shared_examples 'can read hidden and hidden Grants' do
    it { is_expected.to be_able_to(:read, Grant) }
    it { is_expected.to be_able_to(:read, FactoryBot.build(:grant, hidden: true)) }
  end

  shared_examples 'signup Voter and Artist' do
    it { is_expected.to be_able_to(:new, Voter) }
    it { is_expected.to be_able_to(:create, Voter) }

    it { is_expected.to be_able_to(:new, Artist) }
    it { is_expected.to be_able_to(:create, Artist) }
  end

  context 'with nil' do
    let(:user) { nil }

    it_behaves_like 'can manage Admin unless Admin.exists?'
    it_behaves_like 'can read hidden and hidden Grants'

    it { is_expected.not_to be_able_to(:new, GrantSubmission) }
  end

  context 'with admin' do
    let(:user) { FactoryBot.create(:admin) }

    it { is_expected.to be_able_to(:manage, Admin.new) }
    it { is_expected.to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.to be_able_to(:manage, Artist.new) }
    it { is_expected.to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.to be_able_to(:create, GrantSubmission.new) }
    it { is_expected.to be_able_to(:discuss, GrantSubmission.new) }
    it { is_expected.to be_able_to(:edit_questions, GrantSubmission.new) }
    it { is_expected.to be_able_to(:new, GrantSubmission.new) }
    it { is_expected.to be_able_to(:manage, Grant.new) }
    it { is_expected.to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.to be_able_to(:manage, Proposal.new) }
    it { is_expected.to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.to be_able_to(:manage, Voter.new) }
    it { is_expected.to be_able_to(:manage, Vote.new) }

    it { is_expected.not_to be_able_to(:vote, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:edit_answers, GrantSubmission.new) }
  end

  context 'with artist' do
    let!(:user) { FactoryBot.create(:artist, :activated) }
    let!(:artist_survey) { FactoryBot.create(:artist_survey, artist: user) }
    let!(:grant_submission) { FactoryBot.create(:grant_submission, artist: user) }
    let!(:funded_grant_submission) { FactoryBot.create(:grant_submission, :funded, artist: user) }
    let!(:proposal) { FactoryBot.create(:proposal, grant_submission: grant_submission) }

    it_behaves_like 'can manage Admin unless Admin.exists?'
    it_behaves_like 'can read hidden and hidden Grants'
    it_behaves_like 'signup Voter and Artist'

    it { is_expected.to be_able_to(:request_activation, user) }
    it { is_expected.to be_able_to(:manage, artist_survey) }
    [:index, :show, :new, :create, :edit, :update, :destroy, :discuss, :edit_answers].each do |action|
      it { is_expected.to be_able_to(action, grant_submission) }
    end
    it { is_expected.not_to be_able_to(:vote, grant_submission) }
    it { is_expected.not_to be_able_to(:edit_questions, grant_submission) }
    it { is_expected.not_to be_able_to(:destroy, funded_grant_submission) }
    it { is_expected.not_to be_able_to(:index, GrantSubmission.new) }
    it { is_expected.to be_able_to(:manage, proposal) }
    it { is_expected.not_to be_able_to(:index, Artist) }
    it { is_expected.not_to be_able_to(:index, ArtistSurvey) }

    it { is_expected.not_to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Artist.new) }
    it { is_expected.not_to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:reveal_identities, GrantSubmission) }
    it { is_expected.not_to be_able_to(:manage, Grant.new) }
    it { is_expected.not_to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.not_to be_able_to(:manage, Proposal.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Voter.new) }
    it { is_expected.not_to be_able_to(:manage, Vote.new) }

    context 'when not activated' do
      let!(:user) { FactoryBot.create(:artist) }

      it { is_expected.to be_able_to(:manage, user) }
      it { is_expected.to be_able_to(:manage, artist_survey) }

      it { is_expected.not_to be_able_to(:manage, ArtistSurvey.new) }
      it { is_expected.not_to be_able_to(:manage, grant_submission) }
      it { is_expected.not_to be_able_to(:manage, proposal) }
    end
  end

  context 'with voter' do
    let(:user) { FactoryBot.create(:voter, :activated, :verified) }

    let(:voter_submission_assignment) { FactoryBot.build(:voter_submission_assignment, voter: user) }
    let(:voter_survey) { FactoryBot.create(:voter_survey, voter: user) }
    let(:vote) { FactoryBot.build(:vote, voter: user) }

    it_behaves_like 'can manage Admin unless Admin.exists?'
    it_behaves_like 'can read hidden and hidden Grants'
    it_behaves_like 'signup Voter and Artist'

    it { is_expected.to be_able_to(:vote, GrantSubmission.new) }

    [:show, :new, :create, :edit, :update, :request_activation].each do |action|
      it { is_expected.to be_able_to(action, user) }
    end
    it { is_expected.to be_able_to(:manage, vote) }
    it { is_expected.to be_able_to(:manage, voter_survey) }
    it { is_expected.to be_able_to(:read, voter_submission_assignment) }
    it { is_expected.to be_able_to(:read, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:discuss, GrantSubmission.new) }
    it { is_expected.to be_able_to(:read, Grant.new) }
    it { is_expected.not_to be_able_to(:index, Voter) }
    it { is_expected.not_to be_able_to(:index, VoterSurvey) }

    it { is_expected.not_to be_able_to(:manage, ArtistSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Artist.new) }
    it { is_expected.not_to be_able_to(:manage, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:manage, Grant.new) }
    it { is_expected.not_to be_able_to(:manage, GrantsVoter.new) }
    it { is_expected.not_to be_able_to(:manage, Proposal.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSubmissionAssignment.new) }
    it { is_expected.not_to be_able_to(:manage, VoterSurvey.new) }
    it { is_expected.not_to be_able_to(:manage, Voter.new) }
    it { is_expected.not_to be_able_to(:manage, Vote.new) }
    it { is_expected.not_to be_able_to(:new, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:create, GrantSubmission.new) }
    it { is_expected.not_to be_able_to(:reveal_identities, GrantSubmission) }

    context 'when not activated or verified' do
      let(:user) { FactoryBot.create(:voter) }

      [:show, :new, :create, :edit, :update].each do |action|
        it { is_expected.to be_able_to(action, user) }
      end
      it { is_expected.to be_able_to(:manage, voter_survey) }

      it { is_expected.not_to be_able_to(:vote, GrantSubmission.new) }

      it { is_expected.not_to be_able_to(:manage, vote) }
      it { is_expected.not_to be_able_to(:manage, VoterSurvey.new) }
      it { is_expected.not_to be_able_to(:read, voter_submission_assignment) }
      it { is_expected.not_to be_able_to(:read, GrantSubmission.new) }
    end
  end
end
