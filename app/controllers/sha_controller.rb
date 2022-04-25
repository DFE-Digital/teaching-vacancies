class ShaController < ApplicationController
  def sha
    render json: { sha: ENV.fetch("COMMIT_SHA", nil) }
  end
end
