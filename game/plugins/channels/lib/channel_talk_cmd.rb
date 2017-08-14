module AresMUSH
  module Channels
    class ChannelTalkCmd
      include CommandHandler
           
      attr_accessor :channel, :msg
      
      def help
        "`<channel name> <message>` - Talks on a channel."
      end
      
      def parse_args
        self.msg = cmd.args
      end
      
      def log_command
        # Don't log channel chat
      end
      
      def handle
        self.channel = Channels.channel_for_alias(enactor, cmd.root)
        if !self.channel
          client.emit_failure t('dispatcher.huh')
          return
        end
        
        options = Channels.get_channel_options(enactor, self.channel)
        
        # To support MUX-style command syntax, messages can trigger other
        # commands.
        cmd = nil
        if (self.msg == "who")
          cmd = Command.new("channel/who #{self.channel.name}")
        elsif (self.msg == "on")
          if (options && options.aliases)
            cmd = Command.new("channel/join #{self.channel.name}=#{options.aliases.join(",")}")
          else
            cmd = Command.new("channel/join #{self.channel.name}")
          end          
        elsif (self.msg == "off")
          cmd = Command.new("channel/leave #{self.channel.name}")
        elsif (self.msg == "gag" || self.msg == "mute")
          cmd = Command.new("channel/mute #{self.channel.name}")
        elsif (self.msg == "ungag" || self.msg == "unmute")
          cmd = Command.new("channel/unmute #{self.channel.name}")
        elsif (self.msg =~ /^last[ \d]*$/)
          num = self.msg.after("last")
          limit = num.blank? ? "" : "=#{integer_arg(num)}"
          cmd = Command.new("channel/recall #{self.channel.name}#{limit}")
        elsif (self.msg =~ /^recall[ \d]*$/)
          num = self.msg.after("recall")
          limit = num.blank? ? "" : "=#{integer_arg(num)}"
          cmd = Command.new("channel/recall #{self.channel.name}#{limit}")
        end
        
        if (cmd)
          Global.dispatcher.queue_command(client, cmd)
          return
        end

        if (!Channels.is_on_channel?(enactor, self.channel))
          client.emit_failure t('channels.not_on_channel')
          return
        end
        
        if (Channels.is_muted?(enactor, self.channel))
          client.emit_failure t('channels.cant_talk_when_muted')
          return          
        end
          
        title = options.title
        ooc_name = enactor.ooc_name
        name = !title ? ooc_name : "#{title} #{ooc_name}"
        self.channel.pose(name, self.msg)
      end
    end  
  end
end