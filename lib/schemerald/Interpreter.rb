class Interpreter
  DEFAULTS = {
    :"#t" => true,
    :"#T" => true,
    :"#f" => false,
    :"#F" => false,
    :+ => lambda {|*args| args.reduce(:+) },
    :- => lambda {|*args| args.reduce(:-) },
    :* => lambda {|*args| args.reduce(:*) },
    :/ => lambda {|*args|
      if args.reduce(:/) == args.reduce(:fdiv) or args.reduce(:/).class == Float
        args.reduce(:/)
      else
        args.map{|x| x.to_r }.reduce(:/)
      end
    },
    :quotient => lambda {|x, y| x / y },
    :remainder => lambda {|x, y| x.remainder(y) },
    :abs => lambda {|x| x.abs },
    :positive? => lambda {|x| x > 0 ? true : false },
    :negative? => lambda {|x| x < 0 ? true : false },
    :zero? => lambda {|x| x == 0 ? true : false },
    :odd? => lambda {|x| x.odd? ? true : false },
    :even? => lambda {|x| x.even? ? true : false },
    :max => lambda {|*args| args.max },
    :min => lambda {|*args| args.min },
    :modulo => lambda {|x, y| x.modulo(y) },
    :car => lambda {|x| x.car },
    :cdr => lambda {|x| x.cdr },
    :cons => lambda {|x, y| Cons.new(x, y) },
    :list => lambda {|*args| args.consify },
    :pair? => lambda {|x| x.is_a?(Cons) ? true : true }
  }
  FORMS = {
    :define => lambda {|env, forms, name, value| env.define(name, value.scheme_eval(env, forms)) },
    :set! => lambda {|env, forms, name, value| env.set_value(name, value.scheme_eval(env, forms)) },
    :quote => lambda {|env, forms, exp| exp },
    :if => lambda {|env, forms, if_clause, then_clause, else_clause|
      if if_clause.scheme_eval(env, forms) != false
        then_clause.scheme_eval(env, forms)
      else 
        else_clause.scheme_eval(env, forms)
      end
    },
    :lambda => lambda {|env, forms, params, *code| Lambda.new(env, forms, params, *code) },
  }
  def initialize
    @environment = Environment.new(nil, DEFAULTS)
    @special_forms = Environment.new(nil, FORMS)
  end

  def evaluate(string)
    SXP.parse(string).consify.scheme_eval(@environment, @special_forms)
  end

  def repl
    print "> "
    STDIN.each_line do |line|
      begin
        puts self.evaluate(line).to_sxp
      rescue StandardError => e
        puts "ERROR: #{e}"
      end
      print "> "
    end
  end
end