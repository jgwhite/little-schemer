require 'bundler/setup'
require 'treetop'
Treetop.load('little_scheme.treetop')

module LittleScheme
  def self.parse(source)
    LittleSchemeParser.new.parse(source).to_ast
  end

  def self.run(source)
    ast = parse(source)
    env = PRIMITIVES

    results = ast.map { |s|
      env, result = evaluate(env, s)
      result
    }

    results.last
  end

  def self.evaluate(env, s)
    case s
    when Numeric, [] then [env, s]
    when Array then evaluate_list(env, s)
    when Symbol then evaluate_atom(env, s)
    end
  end

  def self.evaluate_list(env, list)
    car, *cdr = list
    env, car = evaluate(env, car)

    if car.respond_to?(:call)
      car.call(env, *cdr)
    else
      results = list.map do |s|
        env, result = evaluate(env, s)
        result
      end

      [env, results]
    end
  end

  def self.evaluate_atom(env, atom)
    result = env[atom] || atom

    [env, result]
  end

  PRIMITIVES = {
    car: -> (env, s) {
      env, s = evaluate(env, s)

      if s.is_a?(Array)
        [env, s.first]
      else
        [env, nil]
      end
    },

    cdr: -> (env, s) {
      env, s = evaluate(env, s)

      if s.is_a?(Array)
        [env, s[1..-1]]
      else
        [env, nil]
      end
    },

    cons: -> (env, s, l) {
      env, l = evaluate(env, l)

      if l.is_a?(Array)
        env, s = evaluate(env, s)

        [env, [s] + l]
      end
    },

    null?: -> (env, s) {
      env, s = evaluate(env, s)

      if s.is_a?(Array)
        [env, s == []]
      else
        [env, nil]
      end
    },

    pair?: -> (env, s) {
      env, s = evaluate(env, s)

      [env, s.is_a?(Array)]
    },

    and: -> (env, *clauses) {
      result = clauses.all? { |clause|
        env, r = evaluate(env, clause)
        r
      }

      [env, result]
    },

    not: -> (env, s) {
      env, result = evaluate(env, s)

      [env, !result]
    },

    eq?: -> (env, a, b) {
      env, a = evaluate(env, a)
      env, b = evaluate(env, b)

      [env, a == b]
    },

    define: -> (env, a, s) {
      env, a = evaluate(env, a)
      env, s = evaluate(env, s)

      env = env.merge(a => s)

      [env, nil]
    },

    lambda: -> (env, names, s) {
      result = -> (_, *values) {
        scope = env.merge(Hash[names.zip(values)])
        _, result = evaluate(scope, s)

        [env, result]
      }

      [env, result]
    },

    quote: -> (env, s) {
      [env, s]
    }
  }
end
