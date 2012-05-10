require 'hashie'
require 'placid/helper'
require 'active_support/inflector' # for `pluralize`

module Placid
  # Base class for RESTful models
  class Model < Hashie::Mash

    include Placid::Helper
    extend Placid::Helper

    # ------------------
    # Instance methods
    # ------------------

    # Set the list of errors on this instance.
    #
    def errors=(new_errors)
      self['errors'] = new_errors
    end

    # Return the list of errors on this instance. If the 'errors' attribute is
    # either not set, or set to nil, then return an empty list.
    #
    def errors
      return self['errors'] if self['errors']
      return []
    end

    # Return true if there are any errors with this model.
    #
    def errors?
      errors && !errors.empty?
    end

    # Return true if the given field is required.
    #
    def required?(field)
      meta = self.class.meta
      return meta[field] && meta[field][:required] == true
    end

    # Save this instance. This creates a new instance, or updates an existing
    # one, with the attributes in this instance. Return true if creation or
    # update were successful, false if there were any errors.
    #
    # @return [Boolean]
    #   true if save was successful, false if there were any errors
    #
    def save
      existing = self.class.find(self.id)
      if existing.nil?
        obj = self.class.create(self.to_hash)
      else
        obj = self.class.update(self.id, self.to_hash)
      end
      self.merge!(obj)
      return !errors?
    end

    # Return the value in the unique_id field.
    #
    def id
      self[self.class.unique_id]
    end


    # ------------------
    # Class methods
    # ------------------

    @unique_id = nil

    # Return the `snake_case` name of this model, based on the derived class
    # name. This name should match the REST API path component used to interact
    # with the corresponding model.
    #
    def self.model
      self.name.gsub(/(.)([A-Z])/, '\1_\2').downcase
    end

    # Get or set the field name used for uniquely identifying instances of this
    # model.
    def self.unique_id(field=nil)
      if field.nil?
        return @unique_id || :id
      else
        @unique_id = field
      end
    end

    # Return a Hashie::Mash of meta-data for this model.
    #
    # FIXME: Avoid calling this more often than needed
    def self.meta
      get_mash(model, 'meta')
    end

    # Return a Hashie::Mash with a list of all model instances.
    #
    def self.list
      get_mashes(model.pluralize)
    end

    # Return a Model instance matching the given id
    #
    # @param [String] id
    #   Identifier for the model instance to fetch
    #
    # @return [Model]
    #
    def self.find(id)
      json = get(model, id)
      return self.new(json)
    end

    # Create a new model instance and return it.
    #
    # @param [Hash] attrs
    #   Attribute values for the new instance
    #
    # @return [Model]
    #
    def self.create(attrs={})
      obj = self.new(attrs)
      json = post(model, attrs)
      obj.merge!(json)
      return obj
    end

    # Update an existing model instance.
    #
    # @param [String] id
    #   Identifier of the model instance to update
    # @param [Hash] attrs
    #   New attribute values to set
    #
    # @return [Model]
    #
    def self.update(id, attrs={})
      obj = self.new(attrs)
      json = put(model, id, attrs)
      obj.merge!(json)
      #obj.errors = json['errors']
      return obj
    end

    # Destroy a model instance.
    #
    # @param [String] id
    #   Identifier for the model instance to delete
    #
    def self.destroy(id)
      delete(model, id)
    end

  end
end

