require 'spec_helper'

describe ActionNetworkRest::Taggings do
  let(:api_key) { 'secret_key' }

  subject { ActionNetworkRest.new(api_key: api_key) }

  describe '#get' do
    let(:tag_id) { '71f8feef-61c8-4e6b-9745-ec1d7752f298' }
    let(:tagging_id) { '82e909f9-1ac7-4952-bbd4-b4690a14bec2' }
    let(:response_body) do
      {
        identifiers: ["action_network:#{tagging_id}"],
        _links: {
          'osdi:person' => {
            href: 'https://actionnetwork.org/api/v2/people/82e909f9-1ac7-4952-bbd4-b4690a14bec2'
          },
          'osdi:tag' => {
            href: "https://actionnetwork.org/api/v2/tags/#{tag_id}"
          }
        }
      }.to_json
    end

    before :each do
      stub_actionnetwork_request("/tags/#{tag_id}/taggings/#{tagging_id}", method: :get)
        .to_return(status: 200, body: response_body)
    end

    it 'should retrieve tagging data' do
      tagging = subject.tags(tag_id).taggings.get(tagging_id)
      expect(tagging.action_network_id).to eq tagging_id
    end
  end

  describe '#create' do
    let(:tag_id) { '71f8feef-61c8-4e6b-9745-ec1d7752f298' }
    let(:person_id) { 'c945d6fe-929e-11e3-a2e9-12313d316c29' }
    let(:tagging_data) { { identifiers: ["external_system:123"] } }
    let(:request_body) do
      {
        identifiers: ["external_system:123"],
        _links: {
          'osdi:person' => {
            href: "https://actionnetwork.org/api/v2/people/#{person_id}"
          }
        }
      }
    end
    let(:tagging_id) { '82e909f9-1ac7-4952-bbd4-b4690a14bec2' }
    let(:response_body) do
      {
        identifiers: [
          "action_network:#{tagging_id}",
          'external_system:123'
        ],
        _links: {
          'osdi:person' => {
            href: "https://actionnetwork.org/api/v2/people/#{person_id}"
          },
          'osdi:tag' => {
            href: "https://actionnetwork.org/api/v2/tags/#{tag_id}"
          }
        }
      }.to_json
    end

    let!(:post_stub) do
      stub_actionnetwork_request("/tags/#{tag_id}/taggings/", method: :post, body: request_body)
        .to_return(status: 200, body: response_body)
    end

    it 'should POST tagging data' do
      tagging = subject.tags(tag_id).taggings.create(tagging_data, person_id: person_id)

      expect(post_stub).to have_been_requested

      expect(tagging.action_network_id).to eq tagging_id
    end
  end

  describe '#delete' do
    let(:tag_id) { '71f8feef-61c8-4e6b-9745-ec1d7752f298' }
    let(:tagging_id) { '82e909f9-1ac7-4952-bbd4-b4690a14bec2' }
    let(:response_body) do
      {
        notice: 'This tagging was successfully deleted.'
      }.to_json
    end

    let!(:delete_stub) do
      stub_actionnetwork_request("/tags/#{tag_id}/taggings/#{tagging_id}", method: :delete)
        .to_return(status: 200, body: response_body)
    end

    it 'should DELETE tagging' do
      result = subject.tags(tag_id).taggings.delete(tagging_id)

      expect(delete_stub).to have_been_requested

      expect(result.notice).to eq 'This tagging was successfully deleted.'
    end
  end
end