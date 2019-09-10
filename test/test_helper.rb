# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'timdex'
require 'byebug'
require 'jwt'
require 'timecop'
require 'vcr'

require 'minitest/autorun'

VCR.configure do |config|
  config.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  config.hook_into :faraday
end
