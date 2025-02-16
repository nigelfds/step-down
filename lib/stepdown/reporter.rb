require 'stepdown/step_group'
require 'stepdown/step_usage'
require 'delegate'

module Stepdown
  class Reporter < Delegator
    
    def initialize(statistics)
      @statistics = statistics
      super @statistics
    end

    def __getobj__
      @statistics  
    end

    def __setobj__(statistics)
      @statistics = statistics
    end

  end
end

