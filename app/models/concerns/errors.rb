module Errors
  extend ActiveSupport::Concern

  class IvalidParameter < StandardError
    def message
      "Input is not correct format"
    end
  end

  class FreePinsError < StandardError ;
    def message
      "You have less pin available."
    end
  end

  class OverBowlingError < StandardError ;
    def message
      "The bowling game is over"
    end
  end
end
