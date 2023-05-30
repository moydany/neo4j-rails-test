class ApplicationController < ActionController::Base
    protect_from_forgery unless: -> { request.format.json? }
    def lifecheck
        render json: { message: 'Hello from the other side (the server)' }
    end
end
