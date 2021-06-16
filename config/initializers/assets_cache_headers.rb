# This will affect assets in /public, /packs e.g. webpacker assets.
# We set cache headers to instruct Cloudfront to cache assets for one year

Rails.application.config.public_file_server.headers = {
  "Cache-Control" => "public, max-age=31536000",
}
