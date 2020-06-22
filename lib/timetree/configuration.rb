# frozen_string_literal: true

require 'logger'

module TimeTree
  # TimeTree apis client configuration.
  class Configuration
    # @return [String]
    attr_accessor :access_token
    # @return [Logger]
    attr_accessor :logger

    def initialize
      logger = Logger.new(STDOUT)
      logger.level = :warn
      @logger = logger
    end
  end
end
