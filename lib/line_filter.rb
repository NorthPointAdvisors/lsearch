class LineFilter

  attr_reader :hash, :line, :params, :ok

  def initialize(hash, params = { })
    @hash = hash.dup
    @params = params
  end

  def line
    @hash[:line]
  end

  def ok?
    @ok = true
    self.class.steps.each do |step_name|
      send "process_#{step_name}"
    end
    @ok
  end

  class << self

    def steps
      @steps ||= []
    end

    def register_step(name)
      steps << name unless steps.include?(name)
    end

  end

end

require File.expand_path(File.dirname(__FILE__) + '/filters/base')
