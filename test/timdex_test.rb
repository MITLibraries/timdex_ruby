# frozen_string_literal: true

require 'test_helper'

class TimdexTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil Timdex::VERSION
  end

  # /ping
  def test_ping
    VCR.use_cassette('ping') do
      response = Timdex.new.ping
      assert_equal('pong', response)
    end
  end

  # /auth
  def test_auth
    VCR.use_cassette('auth') do
      # If you need to regenerate the cassette for this, modify these to real
      # values then scrub the cassette for sensitive info before committing.
      # You can leave the JWT as it expires relatively quickly.
      response = Timdex.new('FAKEUSER', 'FAKEPASS').auth
      jwt = JWT.decode(response, nil, false)
      assert_equal(1, jwt[0]['user_id'])
    end
  end

  def test_invalid_auth
    VCR.use_cassette('invalid auth') do
      response = Timdex.new('fake',
                            'password').auth
      assert_equal('invalid credentials', response['error'])
    end
  end

  # /search
  def test_search
    VCR.use_cassette('anonymous search') do
      response = Timdex.new.search('popcorn')

      assert_equal(200, response['status'])
      assert(response['hits'])
    end
  end

  # /record/:id:
  def test_record
    VCR.use_cassette('anonymous retrieve') do
      response = Timdex.new.retrieve('000346597')
      assert_equal(200, response['status'])
      assert_equal('Popcorn Venus /', response['record'].title)
      assert_equal('000346597', response['record'].id)
      assert_equal('https://library.mit.edu/item/000346597',
                   response['record'].source_link)
      assert_equal('MIT Aleph', response['record'].source)
      assert_equal('https://timdex.mit.edu/api/v1/record/000346597',
                   response['record'].full_record_link)
      assert_equal(['Women in motion pictures.'], response['record'].subjects)
      assert_equal([{ 'location' => 'Hayden Library', 'collection' => 'Stacks',
                      'call_number' => 'PN1995.9.W6.R6 1974',
                      'format' => 'Print volume' }],
                   response['record'].locations)
      assert_equal([{ 'kind' => 'author', 'value' => 'Rosen, Marjorie.' }],
                   response['record'].contributors)
      assert_equal('1974', response['record'].publication_date)
      assert_equal('Text', response['record'].content_type)
      assert_equal(['Print volume'], response['record'].content_format)
      assert_equal(['New York : Avon, 1974, c1973.'],
                   response['record'].imprint)
      assert_equal(['0380001772'], response['record'].isbns)
      assert_nil(response['record'].issns)
      assert_equal(['03816312'], response['record'].oclcs)
      assert_equal('73078740', response['record'].lccn)
      assert_equal(['Marjorie Rosen.', 'Includes index.',
                    'Bibliography: p. 412-424.'], response['record'].notes)
      assert_equal('448 p., [16] p. of plates : ports ; 18 cm.',
                   response['record'].physical_description)
      assert_equal(['English'], response['record'].languages)
      assert_equal('New York (State)', response['record'].place_of_publication)
      assert_nil(response['record'].summary)
    end
  end

  def test_multiple_requests_reuse_valid_jwt
    VCR.use_cassette('multiple requests reuse valid jwt') do
      # If you need to regenerate the cassette for this, modify these to real
      # values then scrub the cassette for sensitive info before committing.
      # You can leave the JWT as it expires relatively quickly.
      t = Timdex.new('FAKEUSER', 'FAKEPASS')
      t.auth
      first_jwt = t.instance_variable_get(:@jwt)
      response = t.search('stuff')
      assert_equal(200, response['status'])
      assert_equal(first_jwt, t.instance_variable_get(:@jwt))
    end
  end

  def test_invalid_jwt_detected
    VCR.use_cassette('invalid jwt detected') do
      # If you need to regenerate the cassette for this, modify these to real
      # values then scrub the cassette for sensitive info before committing.
      # You can leave the JWT as it expires relatively quickly.
      t = Timdex.new('FAKEUSER', 'FAKEPASS')
      t.auth
      assert(t.validate_jwt)
      Timecop.freeze(Date.today + 30) do
        refute(t.validate_jwt)
      end
    end
  end

  def test_authenticated_search
    VCR.use_cassette('authenticated search') do
      # If you need to regenerate the cassette for this, modify these to real
      # values then scrub the cassette for sensitive info before committing.
      # You can leave the JWT as it expires relatively quickly.
      t = Timdex.new('FAKEUSER', 'FAKEPASS')
      response = t.search('stuff')
      assert_equal(200, response['status'])
    end
  end
end
