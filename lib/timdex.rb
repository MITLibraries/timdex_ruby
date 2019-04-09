require 'timdex/version'
require 'dotenv/load'
require 'record'
require 'faraday'
require 'json'
require 'jwt'

# Timdex modules wraps interaction with the public TIMDEX API
class Timdex
  def initialize(username, password)
    @jwt = false
    @username = username
    @password = password
  end

  def setup
    timdex_url = ENV.fetch('TIMDEX_URL', 'https://timdex.mit.edu')
    @conn = Faraday.new(url: timdex_url)
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

    @jwt = JSON.parse(response.body)
  end

  def search(term)
    setup
    auth unless validate_jwt
    @conn.token_auth(@jwt)
    response = @conn.get do |req|
      req.url '/api/v1/search', q: term
      req.headers['Authorization'] = "Bearer #{@jwt}"
    end
    json_results = JSON.parse(response.body)
    parse_results(json_results, response.status)
  end

  def retrieve(id)
    setup
    auth unless validate_jwt
    @conn.token_auth(@jwt)
    response = @conn.get do |req|
      req.url '/api/v1/record/' + id
      req.headers['Authorization'] = "Bearer #{@jwt}"
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

  def parse_results(json_results, status)
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

    return @jwt if Time.now.to_i < expires

    @jwt = nil
  end
end
