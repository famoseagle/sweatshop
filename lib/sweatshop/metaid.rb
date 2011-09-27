def meta_eval(&blk); (class << self; self; end).instance_eval(&blk); end
def meta_def(name, &blk)
  meta_eval { define_method name, &blk }
end

def check_arity!(method, args)
  arity = method.arity
  valid = arity < 0 ? args.size >= arity.abs - 1 : args.size == arity
  raise ArgumentError.new("#{method.name} expects #{arity} arguments") unless valid
end
