# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
#
Rails.application.config.assets.precompile += %w( ckeditor/* )
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'html')
Rails.application.config.assets.register_mime_type('text/html', '.html')
Rails.application.config.assets.precompile += %w( landings/* )
Rails.application.config.assets.precompile += %w( landings.js )
Rails.application.config.assets.precompile += %w( landings.css )
Rails.application.config.assets.precompile += %w( mobile.js )
Rails.application.config.assets.precompile += %w( mobile.css )
