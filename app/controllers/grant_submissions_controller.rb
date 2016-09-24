class GrantSubmissionsController < ApplicationController

  before_filter :initialize_grant_submission

  def initialize_grant_submission
    @grant_submission = GrantSubmission.new
  end

  def grant_submission_params
    params.require(:grant_submission).permit(:name, :proposal, :grant_id, :requested_funding_dollars)
  end

  def create
    @grant_submission = GrantSubmission.new(grant_submission_params)

    @grant_submission.artist_id = current_artist.id

    if @grant_submission.save
      render "success"
    else
      render "failure"
    end
  end
  
  def grant_update_params
    params.require(:grant_submission).permit(:id, :name, :grant_id, :requested_funding_dollars, :proposal)
  end

  def update
    @grant_submission = GrantSubmission.find(params[:id])
    
    if @grant_submission.artist_id != current_artist.id
      logger.debug  "artist id mismatch"
      render "failure"
      return
    end
    
    @grant_submission.name = grant_update_params[:name]
    if grant_update_params[:proposal] != ""
      @grant_submission.proposal = grant_update_params[:proposal]
    end
    @grant_submission.grant_id = grant_update_params[:grant_id]
    @grant_submission.requested_funding_dollars = grant_update_params[:requested_funding_dollars]
 
    if @grant_submission.save
      render "success"
    else
      render "failure"
    end

  end

  def index
    # TODO: load submissions_open from config or db.
    @submissions_open = true
  end
  
  def modify
    begin
      @grant_submission = GrantSubmission.find(params.permit(:id)[:id])
    rescue
      redirect_to action: "index"
      return
    end
    
    render "modify"
  end
end
