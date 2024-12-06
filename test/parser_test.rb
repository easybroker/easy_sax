require 'test_helper'
require 'pry'

module ParserTestHelper
  TEST_XML = %(
    <agencies>
      <agency id="1">
        <name>Foo</name>
        <phone>12345678</phone>
        <properties>
          <property id="2">
            <title>Test 2</title>
            <images>
              <image url="http://test.com/1.jpg"/>
              <image url="http://test.com/2.jpg"/>
            </images>
          </property>
          <property id="3">
            <title>Test 3</title>
            <images>
              <image url="http://test.com/4.jpg"/>
              <image url="http://test.com/5.jpg"/>
            </images>
          </property>
        </properties>
      </agency>
      <agency id="2">
        <name>Bar</name>
        <properties>
          <property id="4">
            <title>Test 4</title>
            <images>
              <image url="http://test.com/3.jpg"/>
              <image url="http://test.com/4.jpg"/>
            </images>
          </property>
        </properties>
      </agency>
    </agencies>
  )

  PROPERTY_1 = {
    attrs: { 'id' => '2' },
    elements: {
      'title' => {
        text: 'Test 2'
      },
      'images' => [
        {
          attrs: { 'url' => 'http://test.com/1.jpg' }
        },
        {
          attrs: { 'url' => 'http://test.com/2.jpg' }
        }
      ]
    }
  }

  PROPERTY_2 = {
    attrs: { 'id' => '3' },
    elements: {
      'title' => {
        text: 'Test 3'
      },
      'images' => [
        {
          attrs: { 'url' => 'http://test.com/4.jpg' }
        },
        {
          attrs: { 'url' => 'http://test.com/5.jpg' }
        }
      ]
    }
  }

  PROPERTY_3 = {
    attrs: { 'id' => '4' },
    elements: {
      'title' => {
        text: 'Test 4'
      },
      'images' => [
        {
          attrs: { 'url' => 'http://test.com/3.jpg' }
        },
        {
          attrs: { 'url' => 'http://test.com/4.jpg' }
        }
      ]
    }
  }

  def test_that_it_has_a_version_number
    refute_nil ::EasySax::VERSION
  end

  def test_target_element_with_no_parents
    agencies = []
    new_parser.parse_each(:agency,
                          ignore: %w[agencies],
                          arrays: %w[properties features images]) do |agency|
      agencies << agency
    end

    assert_equal 2, agencies.size
    first_agency = agencies.first

    assert_equal 1, first_agency.attrs['id'].to_i
    assert_equal 'Foo', first_agency['name'].text
    assert_equal '12345678', first_agency['phone'].text

    assert_equal 2, first_agency['properties'].size
    assert_equal PROPERTY_1.to_s, first_agency['properties'].first.to_h.to_s
    assert_equal PROPERTY_2.to_s, first_agency['properties'].last.to_h.to_s

    last_agency = agencies.last
    assert_equal 2, last_agency.attrs['id'].to_i
    assert_equal 'Bar', last_agency['name'].text
    assert_nil last_agency['phone']

    assert_equal 1, last_agency['properties'].size
    assert_equal PROPERTY_3.to_s, last_agency['properties'].first.to_h.to_s
  end

  def test_target_element_with_parents
    agencies = {}
    properties = {}
    new_parser.parse_each(:property,
                          ignore: %w[agencies properties],
                          arrays: %w[features images]) do |property, agency|
      property_id = property.attrs['id'].to_i
      properties[property_id] = property
      agencies[property_id] = agency
    end

    assert_equal 3, agencies.size
    assert_equal agencies[2], agencies[3]

    first_agency = agencies[2]
    assert_equal 1, first_agency.attrs['id'].to_i
    assert_equal 'Foo', first_agency['name'].text
    assert_equal '12345678', first_agency['phone'].text
    assert_nil first_agency['property']

    assert_equal 'Test 2', properties[2]['title'].text
    assert_equal PROPERTY_1.to_s, properties[2].to_h.to_s
    assert_equal 'Test 3', properties[3]['title'].text
    assert_equal PROPERTY_2.to_s, properties[3].to_h.to_s

    last_agency = agencies[4]
    assert_equal 2, last_agency.attrs['id'].to_i
    assert_equal 'Bar', last_agency.text_for(:name)
    assert_nil last_agency['phone']

    assert_nil last_agency['property']
    assert_equal 'Test 4', properties[4].text_for(:title)
    assert_equal PROPERTY_3.to_s, properties[4].to_h.to_s
  end

  def test_target_element_with_child_arrays
    properties = {}
    new_parser.parse_each(:property,
                          arrays: [:images]) do |property|
      property_id = property.attrs['id'].to_i
      properties[property_id] = property['images'].map { |image| image.attrs['url'] }
    end

    [PROPERTY_1, PROPERTY_2, PROPERTY_3].each do |property|
      urls = property[:elements]['images'].map { |hash| hash[:attrs]['url'] }
      id = property[:attrs]['id'].to_i
      assert_equal urls, properties[id]
    end
  end

  def test_invalid_xml_throws_error
    parser = EasySax.parser(StringIO.new('<test><foo></bar>'))

    assert_raises EasySax::ParseError do
      parser.parse_each(:agent) do
        flunk
      end
    end
  end

  def test_validates_param_options_should_be_arrays
    assert_raises ArgumentError do
      new_parser.parse_each(:property,
                            ignore: 'agencies properties',
                            arrays: %w[features images])
    end

    assert_raises ArgumentError do
      new_parser.parse_each(:property,
                            ignore: %w[agencies properties],
                            arrays: 'features images')
    end
  end
end

class EasySaxParserTest < Minitest::Test
  include ParserTestHelper

  private

  def parser_class
    EasySax::Parser
  end

  def new_parser
    parser_class.new(StringIO.new(TEST_XML))
  end
end

class EasySaxOxParserTest < Minitest::Test
  include ParserTestHelper

  private

  def parser_class
    EasySax::OxParser
  end

  def new_parser
    parser_class.new(StringIO.new(TEST_XML))
  end
end
