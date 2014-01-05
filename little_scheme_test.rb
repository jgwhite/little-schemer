require_relative 'little_scheme'
require 'minitest/autorun'
require 'minitest/pride'

class LittleSchemeTest < MiniTest::Unit::TestCase
  def assert_ast(result, source)
    assert_equal result, LittleScheme.parse(source)
  end

  def assert_result(result, source)
    assert_equal result, LittleScheme.run(source)
  end

  def test_parse
    assert_ast [:atom], "atom"
    assert_ast [:turkey], "turkey"
    assert_ast [1492], "1492"
    assert_ast [:u], "u"
    assert_ast [:"*abc$"], "*abc$"
    assert_ast [[:atom]], "(atom)"
    assert_ast [[:atom, :turkey, :or]], "(atom turkey or)"
    assert_ast [[:atom, :turkey], :or], "(atom turkey) or"
    assert_ast [[[:x, :y], :z]], "((x y) z)"
    assert_ast [[]], "()"
    assert_ast [[[], [], [], []]], "(() () () ())"
  end

  def test_car
    assert_result :a, "(car (a b c))"
    assert_result nil, "(car hotdog)"
    assert_result nil, "(car ())"
  end

  def test_cdr
    assert_result [:b, :c ], "(cdr (a b c))"
    assert_result nil, "(cdr hotdogs)"
    assert_result nil, "(cdr ())"
  end

  def test_cons
    assert_result [:peanut, :butter, :jelly],
                  "(cons peanut (butter jelly))"
    assert_result [[:banana], :peanut, :butter, :jelly],
                  "(cons (banana) (peanut butter jelly))"
    assert_result nil, "(cons ((a b c)) b)"
    assert_result nil, "(cons a b)"
  end

  def test_null
    assert_result true, "(null? ())"
    assert_result true, "(null? (quote ()))"
    assert_result true, "(null? '())"
    assert_result false, "(null? (a b c))"
    assert_result nil, "(null? a)"
  end

  def test_not
    assert_result true, "(not (null? a))"
    assert_result false, "(not (null? ()))"
  end

  def test_pair
    assert_result true, "(pair? ())"
    assert_result false, "(pair? a)"
  end

  def test_define
    assert_result [:b, :c], %{
      (define a (b c))
      a
    }
  end

  def test_lambda
    definition = %{
      (define foo
        (lambda (x)
          (bar x)))
    }

    assert_result [:bar, :a], %{
      #{definition}
      (foo a)
    }

    assert_result :x, %{
      #{definition}
      (foo a)
      x
    }
  end

  def test_atom
    definition = %{
      (define atom?
        (lambda (x)
          (and (not (pair? x)) (not (null? x)))))
    }

    assert_result true, %{
      #{definition}
      (atom? a)
    }

    assert_result false, %{
      #{definition}
      (atom? ())
    }
  end

  def test_eq
    assert_result true, "(eq? Harry Harry)"
    assert_result false, "(eq? margarine butter)"
    assert_result false, %{
      (define l1 ())
      (define l2 (strawberry))

      (eq? l1 l2)
    }
    assert_result true, "(eq? (a) (a))"
    assert_result true, "(eq? 7 7)"
    assert_result false, "(eq? 6 7)"
    assert_result false, %{
      (define l (soured milk))
      (define a milk)

      (eq? (cdr l) a)
    }
    assert_result true, %{
      (define l (beans beans we need jelly beans))

      (eq? (car l) (car (cdr l)))
    }
  end
end
