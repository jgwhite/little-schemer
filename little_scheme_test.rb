require_relative 'little_scheme'
require 'minitest/autorun'
require 'minitest/pride'

class LittleSchemeTest < MiniTest::Unit::TestCase
  def assert_result(result, program)
    assert_equal result, LittleScheme.evaluate(program)
  end

  def test_atoms
    assert_result :atom, 'atom'
    assert_result :turkey, 'turkey'
    assert_result :'1492', '1492'
    assert_result :u, 'u'
  end

  def test_lists
    assert_result [], '()'
    assert_result [:atom], '(atom)'
    assert_result [:atom, :turkey, :or], '(atom turkey or)'
    assert_result [[:atom, :turkey], :or], '((atom turkey) or)'
  end

  def test_car
    assert_result :a, '(car (a b c))'
    assert_result [:a, :b, :c], '(car ((a b c) x y z))'
    assert_result nil, '(car hotdog)'
    assert_result nil, '(car ())'
    assert_result [[:hotdogs]], '(car (((hotdogs)) (and) (pickle) relish))'
    assert_result [:hotdogs], '(car (car (((hotdogs)) (and))))'
  end

  def test_cdr
    assert_result [:b, :c], '(cdr (a b c))'
    assert_result [:x, :y, :z], '(cdr ((a b c) x y z))'
    assert_result [], '(cdr (hamburger))'
    assert_result [:t, :r], '(cdr ((x) t r))'
    assert_result nil, '(cdr hotdogs)'
    assert_result nil, '(cdr ())'
    assert_result [:x, :y], '(car (cdr ((b) (x y) ((c)))))'
    assert_result [[[:c]]], '(cdr (cdr ((b) (x y) ((c)))))'
    assert_result nil, '(cdr (car (a (b (c)) d)))'
  end

  def test_cons
    assert_result [:peanut, :butter, :and, :jelly],
                  '(cons peanut (butter and jelly))'
    assert_result [[:banana, :and], :peanut, :butter, :and, :jelly],
                  '(cons (banana and) (peanut butter and jelly))'
    assert_result nil, '(cons ((a b c)) b)'
  end

  def test_null?
    assert_result true, '(null? ())'
    assert_result false, '(null? (a b c))'
    assert_result false, '(null? a)'
  end

  def test_atom?
    assert_result true, '(atom? Harry)'
    assert_result false, '(atom? (Harry had a heap of apples))'
  end

  def test_eq?
    assert_result true, '(eq? Harry Harry)'
    assert_result false, '(eq? margarine butter)'
  end
end
