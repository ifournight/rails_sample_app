module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def serialize_errors(errors)
    {
      count: errors.count,
      full_messages: errors.full_messages,
      messages: errors.messages
    }
  end

  def deserialize_errors(errors, errors_hash)
    full_messages = errors_hash['full_messages'] if errors_hash
    full_messages.each { |message| errors[:base] << message } if full_messages
  end
end
