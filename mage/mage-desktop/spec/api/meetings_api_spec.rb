require 'spec_helper'

describe 'Meetings API' do

  describe 'GET /api/meetings' do
    let(:method) { :get }
    let(:endpoint) { "/api/meetings" }
    let(:authenticable) { create :user }

    def create_meetings
      [
        create(:meeting),
        create(:meeting),
        create(:meeting, active: false)
      ]
    end

    it_behaves_like "authenticated API endpoint"

    it "responds with an empty collection if there are not meetings" do
      do_api_request
      
      coll = API::Collection.new([])
      expected_body = CollectionRepresenter.new(coll).to_json(participant: authenticable)
      actual_body = response.body

      expect(response.status).to eq(200)
      expect(actual_body).to be_json_eql(expected_body).excluding('_links')
    end

    it "responds with all active meetings if there are any" do
      meetings = create_meetings.select { |m| m.active }

      do_api_request

      coll = API::Collection.new(meetings)
      expected_body = CollectionRepresenter.new(coll).to_json(participant: authenticable)
      actual_body = response.body

      expect(response.status).to eq(200)
      expect(actual_body).to be_json_eql(expected_body).excluding('_links')
    end

  end # GET /api/meetings

  describe 'POST /api/meetings' do
    let(:method) { :post }
    let(:endpoint) { "/api/meetings" }
    let(:device) { create :table }
    let(:authenticable) { device }

    before :each do
      reactive_stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        expected_params = {
          type: "*",
          payload: "*"
        }
        stub.post('/api/messages') { [200, expected_params] }
      end

      Reactive.stub(:instance).and_return ReactiveStub.new(reactive_stubs)
    end

    it_behaves_like "authenticated API endpoint"

    it "should create an meeting and respond with its json representation" do
      do_api_request

      expect(Meeting.count).to eq(1)
      meeting = Meeting.first
      expect(meeting.initiator).to eq(device)

      expected_body = MeetingRepresenter.new(meeting).to_json
      actual_body = response.body

      expect(response.status).to eq(201)
      expect(actual_body).to be_json_eql(expected_body)
    end
  end # POST /api/meetings

end
