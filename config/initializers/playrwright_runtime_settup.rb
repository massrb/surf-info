
if Rails.env.production?
  Rails.logger.info("Installing Playwright browsers at runtime...")
  system('npx playwright install')
end