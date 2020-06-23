# frozen_string_literal: true

module TimeTree
  # Model for TimeTree event or keep.
  class Event < BaseModel
    # @return [Striing]
    attr_accessor :category
    # @return [Striing]
    attr_accessor :title
    # @return [Boolean]
    attr_accessor :all_day
    # @return [Time]
    attr_accessor :start_at
    # @return [Striing]
    attr_accessor :start_timezone
    # @return [Time]
    attr_accessor :end_at
    # @return [String]
    attr_accessor :end_timezone
    # @return [String]
    attr_accessor :recurrences
    # @return [String]
    attr_accessor :recurring_uuid
    # @return [String]
    attr_accessor :description
    # @return [String]
    attr_accessor :location
    # @return [String]
    attr_accessor :url
    # @return [Time]
    attr_accessor :updated_at
    # @return [Time]
    attr_accessor :created_at
    # calendar's id.
    # @return [String]
    attr_accessor :calendar_id

    # @return [TimeTree::User]
    attr_reader :creator
    # @return [TimeTree::Label]
    attr_reader :label
    # @return [Array<TimeTree::User>]
    attr_reader :attendees

    TIME_FIELDS = %i[start_at end_at updated_at created_at].freeze
    RELATIONSHIPS = %i[creator label attendees].freeze

    #
    # Creates an event to the associated calendar.
    #
    # @return [TimeTree::Event]
    # @raise [TimeTree::Error] if @client is not set.
    # @raise [TimeTree::ApiError] if the http response status is not success.
    # @since 0.0.1
    def create
      raise Error, 'client is required.' if @client.nil?

      @client.create_event calendar_id, data_params
    end

    #
    # Creates comment to the event.
    #
    # @return [TimeTree::Activity]
    # @raise [TimeTree::Error] if @client is not set.
    # @raise [TimeTree::ApiError] if the http response status is not success.
    # @since 0.0.1
    def create_comment(message)
      raise Error, '@client is nil.' if @client.nil?

      params = { type: 'activity', attributes: { calendar_id: calendar_id, event_id: id, content: message } }
      activity = to_model params
      return if activity.nil?

      activity.create
    end

    #
    # Updates the event.
    #
    # @return [TimeTree::Event]
    # @raise [TimeTree::Error] if @client is not set.
    # @raise [TimeTree::Error] if the id property is not set.
    # @raise [TimeTree::ApiError] if the http response status is not success.
    # @since 0.0.1
    def update
      raise Error, '@client is nil.' if @client.nil?
      raise Error, 'id is required.' if id.nil?

      @client.update_event calendar_id, id, data_params
    end

    #
    # Deletes the event.
    #
    # @return [true] if the operation succeeded.
    # @raise [TimeTree::Error] if @client is not set.
    # @raise [TimeTree::Error] if the id property is not set.
    # @raise [TimeTree::ApiError] if the http response status is not success.
    # @since 0.0.1
    def delete
      raise Error, '@client is nil.' if @client.nil?
      raise Error, 'id is required.' if id.nil?

      @client.delete_event calendar_id, id
    end

    #
    # convert to a TimeTree request body format.
    #
    # @return [Hash]
    def data_params
      attributes_params = {
        category: category,
        title: title,
        all_day: all_day,
        start_at: start_at.iso8601,
        start_timezone: start_timezone,
        end_at: end_at.iso8601,
        end_timezone: end_timezone,
        description: description,
        location: location,
        url: url
      }
      relationhips_params = {}
      if @relationships[:label]
        label_data = { id: @relationships[:label], type: 'label' }
        relationhips_params[:label] = { data: label_data }
      end
      if @relationships[:attendees]
        attendees_data = @relationships[:attendees].map { |_id| { id: _id, type: 'user' } }
        relationhips_params[:attendees] = { data: attendees_data }
      end
      {
        data: {
          attributes: attributes_params,
          relationships: relationhips_params
        }
      }
    end
  end
end
