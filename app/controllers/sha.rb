class ShaController < ApplicationController
    def sha
        render json: { sha: ENV["COMMIT_SHA"] }
    end
