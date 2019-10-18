require 'test_helper'

class SimpleElementTest < Minitest::Test
  def test_initialize
    element = EasySax::SimpleElement.new('agency', { 'name' => 'simpson', 'phone' => '12345' })
    assert_equal element.attrs[:name], 'simpson'
    assert_equal element.attrs['name'], 'simpson'
    assert_equal element.attrs[:phone], '12345'
    assert_equal element.attrs['phone'], '12345'
  end
end
