require 'treetop'
Treetop.load('little_scheme.treetop')

module LittleScheme
  def self.evaluate(program)
    parse(program).evaluate(env).last
  end

  def self.parse(program)
    LittleSchemeParser.new.parse(program)
  end

  def self.env
    {
      car: -> (l) { l[0] if l.is_a?(Array) },
      cdr: -> (l) { l[1..-1] if l.is_a?(Array) },
      cons: -> (s, l) { [s] + l if l.is_a?(Array) },
      null?: -> (l) { l == [] },
      atom?: -> (l) { l.is_a?(Symbol) },
      eq?: -> (a, b) { a == b }
    }
  end
end
