module AresMUSH
  module Channels
    class ChannelWhoCmd
      include CommandHandler
           
      attr_accessor :name

      def help
        "`channel/who <channel>` - Shows who's on the channel"
      end
      
      def parse_args
        self.name = titlecase_arg(cmd.args)
      end
      
      def required_args
        [ self.name ]
      end
      
      def handle
        Channels.with_an_enabled_channel(self.name, client, enactor) do |channel|
          online_chars = Channels.channel_who(channel)
          names = online_chars.map { |c| "#{c.ooc_name}#{Channels.mute_text(c, channel)}" }
          text = t('channels.channel_who', :name => channel.display_name, :chars => names.join(", "))
          
          client.emit_ooc "%xn#{text}"
        end
      end
    end  
  end
end