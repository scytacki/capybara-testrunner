require 'capybara'
require 'capybara/dsl'

Capybara.current_driver = :selenium
Capybara.app_host = "http://localhost:4020"
include Capybara
visit("/cc/en/current/tests/views.html")
results = evaluate_script('CoreTest.plan.results')
puts results.inspect