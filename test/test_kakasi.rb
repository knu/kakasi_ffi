# -*- coding: utf-8 -*-
require 'helper'

include Kakasi

class TestKakasi < Test::Unit::TestCase
  def test_kakasi
    assert_equal 'KAKASHI nanodesu', eval(<<'', TOPLEVEL_BINDING)
    kakasi('-s -U -Ja -Ha', '案山子なのです')

    text = '本日は晴れのち曇りです。'
    assert_equal '本日 は 晴れ のち 曇り です 。', Kakasi.kakasi('-w', text)
    assert_equal 'honjitsu ha hare nochi kumori desu .', Kakasi.kakasi('-s -Ja -Ha -Ka -Ea -ka', text)
    assert_equal 'ほんじつ は はれ のち くもり です 。', Kakasi.kakasi('-s -JH -kK', text)
  end
end
