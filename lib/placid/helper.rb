require 'uri'
require 'json'
require 'hashie'
require 'rest-client'
require 'active_support/core_ext/array' # for extract_options!
require 'placid/exceptions'

module Placid
  module Helper
    # Escape any special URI characters in `text` (except for '/') and return
    # the escaped string. `nil` is treated as an empty string.
    #
    # @return [String]
    #
    def escape(text)
      # Treat '/' as unreserved
      URI.escape(text.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}/]"))
    end

    # Return a full URL for a REST API request to the given path, relative to
    # the configured `Placid::Config.rest_url`. Each path component is
    # URI-escaped.
    #
    # @example
    #   get_url('people', 'eric') #=> 'http://localhost/people/eric'
    #   get_url('a b', 'c:d')     #=> 'http://localhost/a%20b/c%3Ad'
    #
    # @param [Array] path
    #   Parts of the path to request. These will be escaped and joined with '/'.
    #
    # @return [String]
    #
    def get_url(*path)
      url = Placid::Config.rest_url.to_s.gsub(/\/$/, '')
      joined_path = path.map { |p| escape(p) }.join('/')
      return "#{url}/#{joined_path}"
    end

    # Send a request and return the parsed JSON response.
    #
    # @example
    #   request('get', 'people', 'eric')
    #   request(:put, 'people', 'eric', {:title => "Developer"})
    #
    # @overload request(method, *path, params={})
    #   @param [String, Symbol] method
    #     Request method to use, as a string ('get', 'post', 'put', 'delete')
    #     or symbol (:get, :post, :put, :delete)
    #   @param [Array] path
    #     Path components for the request
    #   @param [Hash] params
    #     Optional parameters to send in the request.
    #
    # @return [Hash]
    #   Parsed response
    #
    # @raise [RestConnectionError]
    #   If there is a problem connecting to the REST API
    # @raise [JSONParseError]
    #   If the response from the REST API cannot be parsed as JSON
    # @raise [PathError]
    #   If any part of the path is nil
    #
    def request(method, *path)
      if path.any? {|p| p.nil?}
        raise PathError, "Cannot use nil as a path component"
      end
      method = method.to_sym
      params = path.extract_options!
      params = {:params => params} if method == :get
      rest_url = get_url(*path)
      begin
        response = RestClient.send(method, rest_url, params)
      rescue RestClient::Exception => e
        response = e.response
      rescue Errno::ECONNREFUSED => e
        raise RestConnectionError,
          "Could not connect to REST API: #{rest_url} (#{e.message})"
      rescue => e
        raise
      end
      # Try to parse the response
      begin
        return JSON.parse(response)
      rescue => e
        raise JSONParseError.new(
          "Cannot parse response from #{rest_url} as JSON", response)
      end
    end

    # Send a GET to a path that returns a single JSON object, and return the
    # result as a Hashie::Mash.
    #
    # @overload get_mash(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hashie::Mash]
    #
    def get_mash(*path)
      json = request(:get, *path)
      begin
        return Hashie::Mash.new(json)
      rescue => e
        raise Placid::JSONParseError,
          "Cannot parse JSON as key-value pairs: #{e.message}"
      end
    end

    # Send a GET to a path that returns a JSON array of objects, and return the
    # result as an array of Hashie::Mash objects.
    #
    # @overload get_mashes(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Array]
    #
    def get_mashes(*path)
      json = request(:get, *path)
      begin
        return json.map {|rec| Hashie::Mash.new(rec)}
      rescue => e
        raise Placid::JSONParseError,
          "Cannot parse JSON as an array of key-value pairs: #{e.message}"
      end
    end

  end
end

