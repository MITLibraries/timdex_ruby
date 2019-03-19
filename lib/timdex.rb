require 'timdex/version'
require 'dotenv/load'
require 'record'
require 'faraday'
require 'json'
require 'jwt'

# Timdex modules wraps interaction with the public TIMDEX API
module Timdex
  TIMDEX_BASE = 'https://timdex.mit.edu/api'.freeze
  TIMDEX_VERSION = '/v1'.freeze
  TIMDEX_URL = TIMDEX_BASE + TIMDEX_VERSION
  TIMDEX_USER = ENV['TIMDEX_USER']
  TIMDEX_PASS = ENV['TIMDEX_PASS']

  def self.setup
    @conn = Faraday.new(url: TIMDEX_URL)
  end

  def self.ping
    setup
    response = @conn.get('/api/v1/ping')
    JSON.parse(response.body)
  end

  def self.auth
    setup
    @conn.basic_auth(TIMDEX_USER, TIMDEX_PASS)
    response = @conn.get('/api/v1/auth')

    @jwt = JSON.parse(response.body)
  end

  def self.search(term)
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

  def self.retrieve(id)
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

  def self.parse_record(json_result, status)
    response = {}
    response['status'] = status
    response['record'] = Record.new(json_result)
    response['raw'] = json_result
    response
  end

  def self.parse_results(json_results, status)
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

  def self.validate_jwt
    return false unless @jwt

    decoded_token = JWT.decode(@jwt, nil, false)
    expires = decoded_token[0]['exp']

    return @jwt if Time.now.to_i < expires

    @jwt = nil
  end
end
