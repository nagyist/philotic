require 'philotic/connection'
module Philotic
  module Publisher
    extend self

    def config
      Philotic::Config
    end

    def publish(event, &block)
      message_metadata = {headers: event.headers}
      message_metadata.merge!(event.message_metadata) if event.message_metadata
      raw_publish(event.payload, message_metadata, &block)
    end

    def raw_publish(payload, message_metadata = {}, &block)

      if Philotic.connected?
        _raw_publish payload, message_metadata, &block
      else
        Philotic.connect! do
          _raw_publish payload, message_metadata, &block
        end
      end
    end

    private
    def _raw_publish(payload, message_metadata = {}, &block)

      publish_defaults = {}
      Philotic::MESSAGE_OPTIONS.each do |key|
        publish_defaults[key] = config.send(key.to_s)
      end
      message_metadata = publish_defaults.merge message_metadata
      message_metadata[:headers] ||= {}
      message_metadata[:headers] = {philotic_firehose: true}.merge(message_metadata[:headers])


      payload.each { |k, v| payload[k] = v.utc if v.is_a? ActiveSupport::TimeWithZone }

      callback = Proc.new do
        Philotic.log_event_published(:debug, message_metadata, payload, 'published event')
        block.call if block
      end

      if config.disable_publish
        EventMachine.next_tick(&callback)
        return
      end

      unless Philotic::Connection.connected?
        Philotic.log_event_published(:error, message_metadata, payload, 'unable to publish event, not connected to amqp broker')
        return
      end
      Thread.new { Philotic::Connection.exchange.publish(payload.to_json, message_metadata, &callback) }
    end
  end
end
