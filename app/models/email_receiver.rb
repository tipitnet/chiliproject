class EmailReceiver

  def create_logger
    tipit_logger = Logger.new("#{Rails.root}/log/received_emails.log", 'daily')
    tipit_logger.level = Logger::DEBUG
    tipit_logger.formatter = proc do |severity, datetime, progname, msg|
      "#{severity} [#{datetime}] - #{progname}: #{msg}\n"
    end
    tipit_logger
  end

  def my_logger
    if Rails.env.production? && ENV['LOG_ENTRIES']
      @@tipit_logger ||= Le.new(ENV['LOG_ENTRIES'])
    else
      @@tipit_logger ||= create_logger
    end
  end

  def receive(request)
    puts request.params
    my_logger.info "mailgun: #{request.params}"
  end

end