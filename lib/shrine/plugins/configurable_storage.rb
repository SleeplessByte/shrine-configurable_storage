# frozen_string_literal: true

require 'shrine'

class Shrine
  module Plugins
    # The {ConfigurableStorage} plugin allows you to register a storage using a
    # config key, and evaluate the storage class dynamically depending on the
    # key. The configuration is global and can be shared across uploaders.
    #
    # Example: Setup storage for images
    #
    #     # in your uploader
    #
    #     plugin :configurable_storage
    #     configurable_storage_name :images
    #
    #     # in an initializer, or somewhere else (because this is lazy)
    #
    #     Shrine::Plugins::ConfigurableStorage.configure do |config|
    #       config[:images] = {
    #         cache: Shrine::Storage::Memory.new,
    #         store: Shrine::Storage::FileSystem.new('uploads', prefix: 'img')
    #       }
    #     end
    #
    module ConfigurableStorage

      class << self
        def fetch(arg, &block)
          configuration.fetch(arg, &block)
        end

        def configure(uploader = nil, *_args)
          return uploader.setup unless block_given?

          yield configuration
        end

        attr_accessor :configuration
      end

      class StorageNotConfigured < ::Shrine::Error
      end

      module ClassMethods
        def setup
          @storage_name = nil
          @memoized_storage = {}
        end

        def configurable_storage_name(name)
          name = name.to_sym
          @storage_name = name
          @memoized_storage.delete(name)
        end

        def find_storage(name)
          return super unless @storage_name

          name = name.to_sym
          @memoized_storage.fetch(name) do
            group = ConfigurableStorage.fetch(@storage_name || :default) do
              ConfigurableStorage.fetch(:default) do
                raise_storage_not_configured(name)
              end
            end
            group[name] || super
          end
        end

        def raise_storage_not_configured(name)
          raise(
            StorageNotConfigured,
            format(
              "Uploader storage not set up for '%<storage_name>s'. " \
              "Make sure you setup the configurable storage: \n\n" \
              "Shrine::Plugins::ConfigurableStorage.configure do |config| \n" \
              "  config[:%<storage_key>s] = { \n"\
              "    cache: Shrine::Storage::..., \n"\
              "    store: Shrine::Storage::... \n"\
              "  }.freeze \n" \
              'end',
              storage_name: name,
              storage_key: @storage_name
            )
          )
        end
      end
    end

    register_plugin(:configurable_storage, ConfigurableStorage)
  end
end

Shrine::Plugins::ConfigurableStorage.configuration = {}
