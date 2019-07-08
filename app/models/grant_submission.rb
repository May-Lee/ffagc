class GrantSubmission < ActiveRecord::Base
  belongs_to :grant
  belongs_to :artist
  has_many :submission_tag

  scope :funded, -> { where('granted_funding_dollars > ?', 0).where(funding_decision: true) }

  has_many :proposals, inverse_of: :grant_submission
  has_many :votes
  has_many :voter_submission_assignments
  has_many :voters, through: :voter_submission_assignments

  accepts_nested_attributes_for :proposals

  mount_uploader :proposal, GrantProposalUploader

  validates :name, presence: true, length: { minimum: 4 }
  # Can't require proposal because modification might not change the proposal.
  # validates :proposal, :presence => true

  validates :grant, presence: true

  validate :funding_requests_syntax, :validate_funding_levels

  # This is supposed to check size before upload but I don't think it does.
  # It does validate after upload, though, so it's not DDOS-proof but it will
  # prevent randos from using the grants server as an ftp site
  validate :proposal_validation, if: :proposal?

  before_save :update_question_and_answer_dates

  def proposal_validation
    return unless proposal.size > 100.megabytes

    logger.warn "rejecting large upload: #{proposal.inspect}"
    errors[:proposal] << 'File must be less than 100MB'
  end

  def funded?
    funding_decision && (granted_funding_dollars || 0) > 0
  end

  def has_questions?
    questions.present?
  end

  def has_answers?
    answers.present?
  end

  def has_other_submissions?
    GrantSubmission.where(artist_id: artist_id).count > 1
  end

  def max_voters
    3
  end

  def num_voters_to_assign
    [max_voters - voter_submission_assignments.count, 0].max
  end

  # Returns a list of strings for each tag on the grant submission.
  def tags(can_view_hidden)
    if !can_view_hidden
      Tag.joins(:submission_tag)
        .where(hidden: false,
              :submission_tags => {:grant_submission_id => id})
        .map(&:name)
    else
      Tag.joins(:submission_tag)
        .where(:submission_tags => {:grant_submission_id => id})
        .map(&:name)
    end
  end

  # Sum up requested dollars for the provided grant ids (for filtering)
  # Returns a hash of the sum of minimum requests and maximum requests.
  def self.requested_funding_dollars_total(id_list)
    min_request_total = 0
    max_request_total = 0
    GrantSubmission.where(id: id_list).each do |gs|
      gs_min = -1
      gs_max = 0
      gs.funding_requests_csv.split(',').each do |token|
        begin
          req = Integer(token)
          if req > gs_max
            gs_max = req
          end
          if req < gs_min || gs_min == -1
            gs_min = req
          end
        rescue ArgumentError
        end
      end
      min_request_total += gs_min
      max_request_total += gs_max
    end
    return {min: min_request_total, max: max_request_total}
  end

  # Sum up granted dollars for the provided grant ids (for filtering) and
  # by query (for further filtering).
  def self.granted_funding_dollars_total(id_list, query)
    grant_submissions = GrantSubmission.where(id: id_list).where(query).sum(:granted_funding_dollars)
  end

  def funding_requests_as_list
    if funding_requests_csv == nil || funding_requests_csv == ""
      return []
    end
    return funding_requests_csv.split(',')
  end

  def funding_requests_as_int_list
    funding_requests_as_list.map{ |r| Integer(r) }
  end

  def by_requested(other)
    self.mean_requested <=> other.mean_requested
  end

  def mean_requested
    mean = 0
    requests = funding_requests_as_int_list
    requests.each { |r| mean += r }
    mean.to_f / requests.length
  end

  private

  def update_question_and_answer_dates
    # TODO: is there a nice way to have this be the same as the new updated_at

    if questions_changed?
      self.questions_updated_at = Time.zone.now
    end

    if answers_changed?
      self.answers_updated_at = Time.zone.now
    end
  end

  def funding_requests_syntax
    errmsg = 'must be comma separated single integers'
    tokens = funding_requests_csv.split(',')
    tokens.each do |token|
      begin
        Integer(token)
      rescue ArgumentError
        errors.add(:funding_requests_csv, errmsg)
      end
    end
  end

  def validate_funding_levels
    levels_array = []
    grant.funding_levels_csv.split(',').each do |token|
      limits = token.split("-")
      if limits.length == 1
        limit = Integer(limits[0])
        levels_array.append([limit, limit])
      elsif limits.length == 2
        lower = Integer(limits[0])
        upper = Integer(limits[1])
        levels_array.append([lower, upper])
      end
    end

    funding_requests_csv.split(',').each do |req|
      req_val = Integer(req)
      valid = false
      levels_array.each do |range|
        if req_val >= range[0] && req_val <= range[1]
          valid = true
          break
        end
      end
      if not valid
        errors.add(:funding_requests_csv, "funding requests match no available levels")
      end
    end
  end
end
