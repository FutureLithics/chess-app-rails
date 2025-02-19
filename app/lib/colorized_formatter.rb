class ColorizedFormatter < ActiveSupport::Logger::SimpleFormatter
  SEVERITY_TO_COLOR_MAP = {
    'DEBUG'   => "\033[0;37m", # White
    'INFO'    => "\033[0;36m", # Cyan
    'WARN'    => "\033[0;33m", # Yellow
    'ERROR'   => "\033[0;31m", # Red
    'FATAL'   => "\033[0;31m", # Red
    'UNKNOWN' => "\033[0;32m"  # Green
  }.freeze

  RESET_COLOR = "\033[0m"

  def call(severity, timestamp, progname, msg)
    color = SEVERITY_TO_COLOR_MAP[severity] || SEVERITY_TO_COLOR_MAP['UNKNOWN']
    formatted_severity = sprintf("%-5s", severity)
    formatted_time = timestamp.strftime("%Y-%m-%d %H:%M:%S.%L")
    "#{color}[#{formatted_severity} #{formatted_time}] #{msg}#{RESET_COLOR}\n"
  end
end 