require 'stepdown/step_collection'

module Stepdown
  class StepInstance
    def initialize
      @steps = []
    end

    def Given(regex,&block)
      define_step(regex,&block)
    end

    def When(regex,&block)
      define_step(regex,&block)
    end

    def Then(regex,&block)
      define_step(regex,&block)
    end

    def define_step(regex,&block)
      @steps << regex
    end

    def self.method_missing(*args)
      #nothing
    end

    def method_missing(*args)
      #nothing
    end

    def self.const_missing(*args)
      self
    end

    def require(*args)
      # do nothing
    end

    def line_matches(line)
      #stripped_line = line.strip.gsub(/^(And|Given|When|Then) (.*)$/,'\2')

      @steps.each_with_index do |regex,i|
        match = regex.match(line)
        if match
          return step_collection.detect{|step| i == step.id}
        end
      end

      return nil
    end

    def step_collection
      return @step_collection if @step_collection
      @step_collection = StepCollection.new
      @steps.each_with_index do |regex, i|
        @step_collection.add_step(i, regex)
      end
      @step_collection
    end
  end
end
