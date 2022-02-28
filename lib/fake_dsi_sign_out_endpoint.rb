# A fake DSI sign out endpoint to be mounted in test environments
# Intercepts requests for the DFE_SIGN_IN_ISSUER (overridden in `environments/test.rb`)
# and redirects if the location is the log out endpoint
class FakeDSISignOutEndpoint
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env["HTTP_HOST"] == "fake.dsi.example.com"

    if env["PATH_INFO"] == "/session/end"
      location = Rack::Utils.parse_nested_query(env["QUERY_STRING"])["post_logout_redirect_uri"]

      [301, { "Location" => location, "Content-Type" => "text/html", "Content-Length" => "0" }, []]
    else
      [404, {}, ["Not found."]]
    end
  end
end
