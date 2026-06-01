# frozen_string_literal: true

# LxmfAdapter provides real LXMF messaging via the Reticulum Network Stack.
# It requires the lxmf Python package and a running rnsd instance.
#
class LxmfAdapter
  class ConnectionError < StandardError; end

  def initialize
    @connected = false
  end

  def connected?
    @connected
  end

  def connect
    # Check if lxmf is available
    if system("which lxmd > /dev/null 2>&1") || system("python3 -c 'import LXMF' 2>/dev/null")
      @connected = true
    else
      Rails.logger.warn "LxmfAdapter: lxmf not installed. Run: pip install lxmf"
      @connected = false
    end
  end

  # Send an LXMF message to a destination hash
  def send_message(destination_hash, subject, body, attachment: nil)
    return false unless connected?

    # Build a temporary Python script to send the message
    script = build_send_script(destination_hash, subject, body, attachment)
    result = run_python(script)

    if result[:success]
      Rails.logger.info "LxmfAdapter: Message sent to #{destination_hash}"
      true
    else
      Rails.logger.error "LxmfAdapter: Failed to send message: #{result[:error]}"
      false
    end
  rescue => e
    Rails.logger.error "LxmfAdapter: Exception sending message: #{e.message}"
    false
  end

  # Check inbox for new messages
  def inbox
    return [] unless connected?

    script = build_inbox_script
    result = run_python(script)

    if result[:success]
      JSON.parse(result[:output] || "[]")
    else
      Rails.logger.error "LxmfAdapter: Failed to check inbox: #{result[:error]}"
      []
    end
  rescue JSON::ParserError => e
    Rails.logger.error "LxmfAdapter: JSON parse error: #{e.message}"
    []
  end

  private

  def build_send_script(destination, subject, body, attachment)
    attachment_code = attachment ? "msg.add_attachment('#{attachment}')" : ""
    <<~PYTHON
      import RNS
      import LXMF
      import time

      reticulum = RNS.Reticulum()
      identity = RNS.Identity()
      destination = RNS.Destination(None, RNS.Destination.OUT, RNS.Destination.SINGLE, "lxmf", "delivery")
      destination.hash = "#{destination}"

      message = LXMF.LXMessage(destination, identity, "#{subject}", "#{body}")
      #{attachment_code}

      router = LXMF.LXMRouter(identity, storagepath="/tmp/lxmf_hub")
      router.send(message)

      # Wait for delivery
      time.sleep(2)
      print("SENT")
    PYTHON
  end

  def build_inbox_script
    <<~PYTHON
      import RNS
      import LXMF
      import json

      reticulum = RNS.Reticulum()
      identity = RNS.Identity()
      router = LXMF.LXMRouter(identity, storagepath="/tmp/lxmf_hub")

      messages = []
      for msg in router.get_unread_messages():
        messages.append({
          "sender": msg.source_hash.hex() if msg.source_hash else "unknown",
          "subject": msg.title,
          "body": msg.content,
          "timestamp": msg.timestamp
        })

      print(json.dumps(messages))
    PYTHON
  end

  def run_python(script)
    require "tempfile"
    
    Tempfile.create(["lxmf_script", ".py"]) do |f|
      f.write(script)
      f.close
      
      output = `python3 #{f.path} 2>&1`
      success = $?.success?
      
      { success: success, output: output, error: success ? nil : output }
    end
  end
end
