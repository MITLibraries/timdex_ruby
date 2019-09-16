# frozen_string_literal: true

require 'timdex/version'
require 'record'
require 'faraday'
require 'json'
require 'jwt'

# Timdex modules wraps interaction with the public TIMDEX API
class Timdex
  def initialize(username = nil, password = nil)
    @jwt = false
    @username = username
    @password = password
  end

  def setup
    timdex_url = ENV.fetch('TIMDEX_URL', 'https://timdex.mit.edu')
    @conn = Faraday.new(url: timdex_url) do |faraday|
      faraday.response :logger if ENV['DEBUG']
      faraday.adapter  Faraday.default_adapter
    end
  end

  def ping
    setup
    response = @conn.get('/api/v1/ping')
    JSON.parse(response.body)
  end

  def auth
    setup
    @conn.basic_auth(@username, @password)
    response = @conn.get('/api/v1/auth')

    if response.status == 200
      @jwt = JSON.parse(response.body)
    else
      @jwt = nil
      JSON.parse(response.body)
    end
  end

  def auth?
    if @username.nil? || @password.nil?
      false
    else
      true
    end
  end

  def search(term)
    setup

    if auth?
      auth unless validate_jwt
      @conn.token_auth(@jwt)
    end

    response = @conn.get do |req|
      req.url '/api/v1/search', q: term
      req.headers['Authorization'] = "Bearer #{@jwt}" if auth?
    end

    parse_results(response.body, response.status)
  end

  def retrieve(id)
    setup
    auth unless validate_jwt
    @conn.token_auth(@jwt)
    response = @conn.get do |req|
      req.url '/api/v1/record/' + id
      req.headers['Authorization'] = "Bearer #{@jwt}" if auth?
    end
    json_result = JSON.parse(response.body)
    parse_record(json_result, response.status)
  end

  def parse_record(json_result, status)
    response = {}
    response['status'] = status
    response['record'] = Record.new(json_result)
    response['raw'] = json_result
    response
  end

  def parse_results(results, status)
    json_results = JSON.parse(results)
    results = {}
    results['status'] = status
    results['hits'] = json_results['hits']
    records = []
    json_results['results'].each do |result|
      records << Record.new(result)
    end
    results['records'] = records
    results
  end

  def validate_jwt
    return false unless @jwt

    decoded_token = JWT.decode(@jwt, nil, false)
    expires = decoded_token[0]['exp']

    return true if Time.now.to_i < expires

    @jwt = nil
  end
end
