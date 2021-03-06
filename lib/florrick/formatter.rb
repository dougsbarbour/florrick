module Florrick
  class Formatter

    class << self
      # Return all formatters available
      def formatters
        @formatters ||= {}
      end

      # Add a new global formatter
      def add(name, types = [], &block)
        formatters[name.to_sym] = self.new(name, types, &block)
      end

      # Run a string through a given formatter and return the result. If not possible, return false.
      def convert(name, value, argument = nil)
        if formatter = formatters[name.to_sym]
          formatter.convert(value, argument)
        else
          false
        end
      end
    end

    def initialize(name, types, &block)
      @name, @types, @block = name, types, block
    end

    def convert(value, argument = nil)
      if @types.empty? || @types.any? { |t| value.is_a?(t)}
        @block.call(value, argument)
      else
        false
      end
    rescue
      '???'
    end

  end
end
