module DFESignIn
  class ExternalServerError < StandardError; end
  class ForbiddenRequestError < StandardError; end
  class UnknownResponseError < StandardError; end

  class API
    USERS_PAGE_SIZE = 1000
    APPROVERS_PAGE_SIZE = 1000

    def users(page: 1)
      perform_request('/users', page, USERS_PAGE_SIZE)
    end

    def approvers(page: 1)
      perform_request('/users/approvers', page, APPROVERS_PAGE_SIZE)
    end

    private

    def perform_request(endpoint, page, page_size)
      token = generate_jwt_token
      response = HTTParty.get(
        "#{DFE_SIGN_IN_URL}#{endpoint}?page=#{page}&pageSize=#{page_size}",
        headers: { 'Authorization' => "Bearer #{token}" }
      )

      raise ExternalServerError if response.code.eql?(500)
      raise ForbiddenRequestError if response.code.eql?(403)
      raise UnknownResponseError unless response.code.eql?(200)

      JSON.parse(response.body)
    end

    def generate_jwt_token
      payload = {
        iss: 'schooljobs',
        exp: (Time.now.getlocal + 60).to_i,
        aud: 'signin.education.gov.uk'
      }

      JWT.encode(payload, DFE_SIGN_IN_PASSWORD, 'HS256')
    end
  end

  private

  def error_message_for(response)
    response['message'] || 'failed request'
  end

  def number_of_pages
    response = api_response
    raise (response['message'] || 'failed request') if response['numberOfPages'].nil?

    response['numberOfPages']
  end

  def users_nil_or_empty?(response)
    response['users'].blank? || response['users'].first.blank?
  end

  def get_response_pages
    response_pages = []
    (1..number_of_pages).each do |page|
      response = api_response(page: page)
      if users_nil_or_empty?(response)
        Rollbar.log(:error,
          'DfE Sign In API responded with nil users')
        raise error_message_for(response)
      end
      response_pages.push(response['users'])
    end
    response_pages
  end
end
