module Sme::Extensions
  module Hash

    def to_tree(sep='/')
      ret = {}

      each do |key, value|
        parts = key.split(sep)
        last = parts.pop
        parts.inject(ret) { |hash, part| hash[part] ||= {} }[last] = value
      end

      ret
    end

  end # module Hash
end # module Sme::Extensions

::Hash.send(:include, Sme::Extensions::Hash)
