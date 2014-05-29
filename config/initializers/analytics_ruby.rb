Analytics = AnalyticsRuby       # Alias for convenience
Analytics.init({
    secret: '7jbmp1kox0',          # The write key for tomwilshere/gitrics
    on_error: Proc.new { |status, msg| print msg }  # Optional error handler
})