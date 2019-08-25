# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Exclude my hacky templates from precompilation
Rails.application.config.assets.precompile = [ Proc.new{ |path| !File.extname(path).in?(['.js', '.css', '.tmpl']) }, /application.(css|js)$/ ]
Rails.application.config.assets.precompile += %w( votes/index.js voters/index.js voters/new.js admins/grant_submissions/index.js grant_submissions/new.js )
