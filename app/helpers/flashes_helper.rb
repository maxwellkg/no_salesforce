module FlashesHelper

  def flash_collection
    FlashMessage.collection_from_flash_hash(flash)
  end

  # updating the flashes will reset the user's view of flash messages
  # this means that any previous messages will be removed
  #
  # if you would like to preserve existing messages and add new ones, use
  # the append_flashes method instead

  def replace_flashes
    turbo_stream.replace("tf-flashes") do
      render partial: "flashes/flash_messages"
    end
  end

  # appending the flashes will add any new flash messages to the view, but without
  # removing the existing messages
  #
  # this can be useful in cases where new messages may be generated before we want to 
  # remove the previous ones from the user's view

  def append_flashes
    turbo_stream.append("tf-flashes") do
      render partial: "flashes/flash_message", collection: flash_collection
    end
  end

end
