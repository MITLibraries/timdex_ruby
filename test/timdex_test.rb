require 'test_helper'

class TimdexTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Timdex::VERSION
  end

  # /ping
  def test_ping
    response = ::Timdex.new('fakeuser', 'fakepass').ping
    assert_equal('pong', response)
  end

  # /auth
  def test_auth
    response = ::Timdex.new(ENV['TIMDEX_USER'],
                            ENV['TIMDEX_PASS']).auth

    jwt = JWT.decode(response, nil, false)
    assert_equal(1, jwt[0]['user_id'])
  end

  # /search
  def test_search
    response = ::Timdex.new(ENV['TIMDEX_USER'],
                            ENV['TIMDEX_PASS']).search('popcorn')

    assert_equal(200, response['status'])
    assert(response['hits'])
  end

  # /record/:id:
  def test_record
  end
end
