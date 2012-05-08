require 'uri'
require 'json'
require 'hashie'
require 'rest-client'

module Placid
  module Helper
    # Escape any special URI characters in `text` and return the escaped string.
    # `nil` is treated as an empty string.
    #
    # @return [String]
    #
    def escape(text)
      URI.escape(text.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    # If the last arg in `args` is a hash, pop it off and return it. Otherwise,
    # return an empty hash. `args` is modified in-place. Behaves like
    # ActiveSupport's `String#extract_options!` method.
    #
    # @param [Array] args
    #   Zero or more arguments, the last of which might be a Hash.
    #
    # @return [Hash]
    #
    def extract_options(args)
      args.last.is_a?(::Hash) ? args.pop : {}
    end

    # Return a full URL for a REST API request to the given path, relative to
    # the configured `Placid::Config.rest_url`. Each path component is
    # URI-escaped.
    #
    # @example
    #   url('people', 'eric') #=> 'http://localhost/people/eric'
    #   url('a b', 'c:d')     #=> 'http://localhost/a%20b/c%3Ad'
    #
    # @param [Array] path
    #   Parts of the path to request. These will be escaped and joined with '/'.
    #
    # @return [String]
    #
    def url(*path)
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
    #     Request method to use ('get', 'post', 'put', 'delete', etc.)
    #   @param [Array] path
    #     Path components for the request
    #   @param [Hash] params
    #     Optional parameters to send in the request.
    #
    # @return [Hash]
    #   Parsed response, or an empty hash if parsing failed
    #
    def request(method, *path)
      method = method.to_sym
      params = extract_options(path)
      params = {:params => params} if method == :get
      base_url = Placid::Config.rest_url
      begin
        response = RestClient.send(method, url(*path), params)
      rescue URI::InvalidURIError => e
        # TODO
        raise
      rescue Errno::ECONNREFUSED
        # TODO
        raise
      rescue RestClient::Exception => e
        response = e.response
      rescue => e
        # FIXME: Diaper pattern. e.response may not be available with certain
        # exceptions, or may not make any sense (like when server is down)
        raise
      end
      return JSON.parse(response) rescue {}
    end

    # Send a GET request and return the parsed JSON response.
    #
    # @example
    #   get('people', 'eric')
    #   get('people', {:name => 'eric'})
    #
    # @overload get(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hash]
    #   Parsed response, or an empty hash if parsing failed
    #
    def get(*path)
      request('get', *path)
    end

    # Send a POST request and return the parsed JSON response.
    #
    # @example
    #   post('people', 'new', {:name => 'eric'})
    #
    # @overload post(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hash]
    #   Parsed response, or an empty hash if parsing failed
    #
    def post(*path)
      request('post', *path)
    end

    # Send a PUT request and return the parsed JSON response.
    #
    # @example
    #   put('people', 'eric', {:title => 'Developer'})
    #
    # @overload put(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hash]
    #   Parsed response, or an empty hash if parsing failed
    #
    def put(*path)
      request('put', *path)
    end

    # Send a DELETE request and return the parsed JSON response.
    #
    # @example
    #   delete('people', 'eric')
    #   delete('people', {:name => 'eric'})
    #
    # @overload delete(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hash]
    #   Parsed response, or an empty hash if parsing failed
    #
    def delete(*path)
      request('delete', *path)
    end

    # Send a GET to a path that returns JSON, and return the result as a Hashie::Mash.
    #
    # @overload get_mash(*path, params={})
    #   See {#request} for allowed parameters.
    #
    # @return [Hashie::Mash]
    #
    def get_mash(*path)
      json = get(*path)
      # Hash-like?
      if json.respond_to?(:each_pair)
        return Hashie::Mash.new(json)
      # Array-like?
      elsif json.respond_to?(:map)
        return json.map {|rec| Hashie::Mash.new(rec)}
      # Unknown
      else
        return nil # FIXME
      end
    end

  end
end

