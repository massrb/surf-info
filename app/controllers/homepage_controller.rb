class HomepageController < ApplicationController

  def index
  end

  def summary
    @results = Scraper::SurfSummary.scrape_and_summarize
    render plain: @results.join("\n")
  end
end
