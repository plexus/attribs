require 'anima'

class Attribs < Module
  attr_reader :defaults, :names

  def initialize(*attrs)
    @defaults   = attrs.last.instance_of?(Hash) ? attrs.pop : {}
    @names = (attrs + @defaults.keys).uniq
  end

  def add(*attrs)
    defaults = attrs.last.instance_of?(Hash) ? attrs.pop : {}
    self.class.new(*[*(names+attrs), @defaults.merge(defaults)])
  end

  def remove(*attrs)
    self.class.new(*[*(names-attrs), @defaults.reject {|k| attrs.include?(k) }])
  end

  def included(descendant)
    descendant.module_exec(self) do |this|
      include InstanceMethods,
              Anima.new(*this.names)

      define_singleton_method(:attributes) { this }
    end
  end
end

require 'attribs/instance_methods'
