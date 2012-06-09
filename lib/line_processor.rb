class LineProcessor

  attr_reader :line, :result

  def initialize(line)
    @line   = line.dup
    @result = { :original => line.dup }
  end

  def process
    self.class.steps.each do |step_name|
      send "process_#{step_name}"
    end
    result[:line] = line
    result
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

require File.expand_path(File.dirname(__FILE__) + '/processors/base')
require File.expand_path(File.dirname(__FILE__) + '/processors/extra')
