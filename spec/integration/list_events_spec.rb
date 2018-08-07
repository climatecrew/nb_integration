# frozen_string_literal: true

require 'support/rack_test_helper'

RSpec.describe 'GET /api/events' do
  include RackTestHelper

  let(:slug) { 'test_slug' }
  let(:access_token) { SecureRandom.hex }

  context 'invalid request' do
    it 'returns 422 when missing parameters' do
      get '/api/events', {}, test_rack_env

      expect(last_response.status).to eq(422)
      expect(JSON.parse(last_response.body)).to match_json_expression(
        "errors": [{ "title": 'missing slug parameter' }]
      )
    end

    it 'returns JSON on bad requests' do
      get '/api/events', {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
    end

    it 'returns JSON even when the server has an error' do
      allow(Account).to receive(:where).and_raise(RuntimeError, 'bad')

      get "/api/events?slug=#{slug}", {}, test_rack_env

      expect(last_response.headers['Content-Type']).to eq('application/json')
      expect { JSON.parse(last_response.body) }.not_to raise_error
    end
  end

  context 'when request is successful' do
    before do
      Account.create(nb_slug: slug, nb_access_token: access_token)
    end

    it 'returns 200' do
      get "/api/events?slug=#{slug}", {}, test_rack_env

      expect(last_response.status).to eq(200)
    end

    it 'returns a list of events for that slug' do
      nb_event = JSON.parse(File.read('./spec/fixtures/nb_events_show.json'))

      Event.create(nb_slug: slug,
                   nb_event: JSON.generate(nb_event))
      Event.create(nb_slug: 'other_slug', nb_event: '{}')

      get "/api/events?slug=#{slug}", {}, test_rack_env

      data = JSON.parse(last_response.body)
      expect(data).to match_json_expression(data: [nb_event])
    end

    context 'when given a NationBuilder author id' do
      it 'filters events to that author' do
        nb_event = JSON.parse(File.read('./spec/fixtures/nb_events_show.json'))

        Event.create(nb_slug: slug,
                     author_nb_id: 1,
                     nb_event: JSON.generate(nb_event))
        Event.create(nb_slug: slug,
                     author_nb_id: 2,
                     nb_event: JSON.generate(nb_event))

        get "/api/events?slug=#{slug}&author_nb_id=2", {}, test_rack_env

        data = JSON.parse(last_response.body)
        expect(data).to match_json_expression(data: [nb_event])
      end
    end
  end
end
