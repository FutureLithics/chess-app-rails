# frozen_string_literal: true

Capybara.save_path = Rails.root.join('tmp/capybara')
Capybara.server = :puma, { Silent: true }
Capybara.default_max_wait_time = 5

# Chrome 158 rejects Capybara 3.40's wildcard CDP origin during session reset.
# Clear the same browser state without the unsupported wildcard request.
module ChromeResetCompatibility
  def reset!
    return unless @browser

    begin
      @browser.execute_script('window.localStorage.clear(); window.sessionStorage.clear();')
    rescue Selenium::WebDriver::Error::WebDriverError
      nil
    end

    @browser.manage.delete_all_cookies
    @browser.navigate.to('about:blank')
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeResetCompatibility)

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--window-size=1400,1000')

  chrome_binary = ENV['CHROME_BIN']
  chrome_binary ||= [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing'
  ].find { |path| File.executable?(path) }
  selenium_arch = RUBY_PLATFORM.include?('arm64') ? 'mac-arm64' : 'mac-x64'
  chrome_binary ||= Dir[
    File.expand_path("~/.cache/selenium/chrome/#{selenium_arch}/**/Google Chrome for Testing")
  ].max

  options.binary = chrome_binary if chrome_binary

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :headless_chrome
  end

  config.after(type: :system) do |example|
    next unless example.exception

    timestamp = Time.current.strftime('%Y%m%d-%H%M%S')
    name = example.full_description.parameterize
    save_page("#{timestamp}-#{name}.html")
    save_screenshot("#{timestamp}-#{name}.png")
  end
end
