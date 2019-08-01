require 'net/http'
require 'uri'

module AresMUSH

  module Events
    class EventCreateCmd
      include CommandHandler
      
      attr_accessor :title, :date_time_desc
      
      def parse_args
        args = cmd.parse_args(ArgParser.arg1_equals_arg2)
        self.title = titlecase_arg(args.arg1)
        self.date_time_desc = trim_arg(args.arg2)
      end
      
      def required_args
        [ self.title, self.date_time_desc ]
      end
      
      def handle
        datetime, desc, error = Events.parse_date_time_desc(self.date_time_desc)
        
        if (error)
          client.emit_failure error
          return
        end
        
        Events.create_event(enactor, self.title, datetime, desc)
        client.emit_success t('events.event_created')
        res = Net::HTTP.post URI('https://discordapp.com/api/webhooks/605822739374276661/w9ouIBZq8vspYNBYLDD34Xp0pfGMtCEA7wcEWjQx9BZGGZQAqmAN5CGG6qSrOoKf_q47'),
          { "message": "this is event text" }.to_json,
          "Content-Type" => "application/json"
​
        Global.logger.debug "Debugging response from discord"
        Global.logger.debug res
      end
    end
  end
end
