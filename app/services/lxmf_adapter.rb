# frozen_string_literal: true

# LxmfAdapter wraps RnsAdapter to provide a higher-level interface
# for LXMF messaging operations.
#
class LxmfAdapter
  def initialize(rns_adapter = nil)
    @rns = rns_adapter || RnsAdapter.new
    @rns.connect unless @rns.connected?
  end

  def send_message(destination_hash, subject, body, attachment: nil)
    @rns.send_lxmf(destination_hash, subject, body, attachment: attachment)
  end

  def inbox
    @rns.lxmf_inbox
  end

  def conversations
    messages = inbox
    messages.group_by { |m| m["sender"] || m["from"] }
            .transform_values { |msgs| msgs.sort_by { |m| m["timestamp"] || m["sent_at"] }.reverse }
  end

  def peer_conversation(destination_hash)
    inbox.select { |m| m["sender"] == destination_hash || m["from"] == destination_hash }
         .sort_by { |m| m["timestamp"] || m["sent_at"] }
  end
end
