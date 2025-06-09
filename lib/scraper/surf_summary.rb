# lib/scraper/surf_summary.rb

require 'playwright'

module Scraper
  class SurfSummary
    def self.scrape_and_summarize
      # urls = File.readlines('urls.txt').map(&:strip).reject(&:empty?)

# https://www.surf-forecast.com/breaks/The-Wall_1/forecasts/latest/six_day
# https://www.surf-forecast.com/breaks/Long-Sands/forecasts/latest/six_day
# https://www.surf-forecast.com/breaks/Kennebunk-Beach/forecasts/latest/six_day
# https://www.surf-forecast.com/breaks/Point-Judithlighthouse/forecasts/latest/six_day
# https://www.surf-forecast.com/breaks/Sachuest-Beach/forecasts/latest/six_day
      urls = [
        'https://www.surf-forecast.com/breaks/Point-Judithlighthouse/forecasts/latest/six_day'
      ]
      results = []

      Playwright.create(playwright_cli_executable_path: 'node_modules/.bin/playwright') do |playwright|
        browser = playwright.chromium.launch(headless: true)
        page = browser.new_page

        urls.each do |url|
          page.goto(url)
          page.wait_for_load_state
          page.evaluate("window.scrollTo(0, document.body.scrollHeight)")
          sleep 2

          begin
            page.wait_for_selector('.star-rating__rating--2', timeout: 10_000)
          rescue
            next
          end

          cells = page.query_selector_all('.forecast-table__cell--has-image')[0, 9]
          ratings = cells.map do |cell|
            cell.query_selector(
              '.star-rating__rating--2, ' \
              '.star-rating__rating--3, ' \
              '.star-rating__rating--4, ' \
              '.star-rating__rating--5'
            )
          end.compact

          rating_counts = Hash.new(0)
          ratings.each do |r|
            classes = r.get_attribute("class")
            next unless classes

            rating = classes.split.find { |cls| cls.start_with?("star-rating__rating--") }
            rating_num = rating.split("--").last if rating
            rating_counts[rating_num] += 1 if rating_num
          end

          unless rating_counts.empty?
            summary = rating_counts.sort.map { |num, count| "#{num} Stars (#{count})" }.join(", ")
            results << "URL: #{url}\nSummary: #{summary}\n"
          end
        end

        browser.close
      end

      results
    end
  end
end
