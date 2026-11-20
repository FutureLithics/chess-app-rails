# frozen_string_literal: true

require 'timeout'

module BoardHelpers
  def replace_board(game, pieces)
    game.pieces.delete_all

    pieces.each do |attributes|
      game.pieces.create!(
        {
          active: true,
          moved: false,
          rating: 1
        }.merge(attributes)
      )
    end
  end

  def board_square(x, y)
    "[data-piece-x='#{x}'][data-piece-y='#{y}']"
  end

  def wait_for_stimulus_controller(selector, identifier)
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop do
        connected = page.evaluate_script(<<~JAVASCRIPT)
          window.Stimulus && Array.from(document.querySelectorAll(#{selector.to_json})).some((element) =>
            window.Stimulus.getControllerForElementAndIdentifier(
              element,
              #{identifier.to_json}
            ) !== null
          )
        JAVASCRIPT

        break if connected

        sleep 0.05
      end
    end
  rescue Timeout::Error
    controllers = page.evaluate_script(
      'window.Stimulus ? window.Stimulus.controllers.map((controller) => controller.identifier) : []'
    )
    modules = page.evaluate_script(
      'window.Stimulus ? Array.from(window.Stimulus.router.modulesByIdentifier.keys()) : []'
    )
    element_count = page.evaluate_script("document.querySelectorAll(#{selector.to_json}).length")
    browser_logs = page.driver.browser.logs.get(:browser).map(&:message)
    raise "Stimulus controller #{identifier.inspect} did not connect " \
          "(registered: #{modules.inspect}; connected: #{controllers.inspect}; " \
          "#{element_count} matching elements; " \
          "browser logs: #{browser_logs.inspect})"
  end
end

RSpec.configure do |config|
  config.include BoardHelpers, type: :system
end
