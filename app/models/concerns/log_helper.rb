module LogHelper
  def cpu_log(message)
    "\e[1;36m🤖 #{message}\e[0m"  # Bold Cyan with robot emoji
  end

  def error_log(message)
    "\e[1;31m❌ #{message}\e[0m"  # Bold Red with X emoji
  end

  def success_log(message)
    "\e[1;32m✅ #{message}\e[0m"  # Bold Green with checkmark emoji
  end

  def move_log(message)
    "\e[1;33m♟️  #{message}\e[0m"  # Bold Yellow with chess piece emoji
  end

  def game_log(message)
    "\e[1;35m🎮 #{message}\e[0m"  # Bold Magenta with game controller emoji
  end
end 