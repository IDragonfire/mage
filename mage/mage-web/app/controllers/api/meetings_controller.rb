class API::MeetingsController < API::ApplicationController
  before_filter :authenticate_from_token!
  before_filter :authorize_device!, only: :create
  before_filter :meeting_filter, only: :show

  def index
    meetings = Meeting.active.map { |m| MeetingRepresenter.new(m) }
    coll = API::Collection.new(meetings, {
      self: api_meetings_url
    })

    render json: CollectionRepresenter.new(coll)
  end # index

  def show
    decorator = MeetingRepresenter.new(@meeting)
    render json: decorator
  end # show

  def create
    meeting = Meeting.new initiator: current_device

    if meeting.save
      response = MeetingRepresenter.new(meeting)
      status = :created
    else
      response = meeting.errors
      status = :unprocessable_entity
    end

    render json: response, status: status
  end # index

end