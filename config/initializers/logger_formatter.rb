class ColorizedFormatter < Logger::Formatter
  SEVERITY_TO_COLOR = {
    'DEBUG' => "\e[0;37m", # White
    'INFO'  => "\e[0;36m", # Cyan
    'WARN'  => "\e[0;33m", # Yellow
    'ERROR' => "\e[0;31m", # Red
    'FATAL' => "\e[0;35m"  # Magenta
  }.freeze

  def call(severity, time, progname, msg)
    color = SEVERITY_TO_COLOR[severity] || "\e[0m"
    reset_color = "\e[0m"
    
    # If msg already contains color codes, don't wrap it in additional colors
    if msg.to_s.include?("\e[")
      "#{time.strftime('%Y-%m-%d %H:%M:%S.%L')} #{severity} -- : #{msg}\n"
    else
      "#{time.strftime('%Y-%m-%d %H:%M:%S.%L')} #{color}#{severity}#{reset_color} -- : #{color}#{msg}#{reset_color}\n"
    end
  end
end 