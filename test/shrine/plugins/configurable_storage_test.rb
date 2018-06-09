# frozen_string_literal: true

require_relative '../../test_helper'

require 'shrine'
require 'shrine/storage/memory'
require 'shrine/plugins/processing'

class Shrine
  module Plugins
    class ConfigurableStorageTest < Minitest::Test

      class MyUploader < Shrine
        plugin :processing
        plugin :configurable_storage
        configurable_storage_name :foo

        process(:store) do |io, _|
          io.download
        end
      end

      class OtherUploader < Shrine
        plugin :configurable_storage
        configurable_storage_name :bar
      end

      def setup_no_storage
        Shrine::Plugins::ConfigurableStorage.configure(&:clear)
      end

      def setup_foo_storage
        setup_no_storage

        cache_storage = Shrine::Storage::Memory.new
        store_storage = Shrine::Storage::Memory.new

        Shrine::Plugins::ConfigurableStorage.configure do |config|
          config[:foo] = {
            cache: cache_storage,
            store: store_storage
          }
        end

        [cache_storage, store_storage]
      end

      def setup_default_storage
        setup_no_storage

        cache_storage = Shrine::Storage::Memory.new
        store_storage = Shrine::Storage::Memory.new

        Shrine::Plugins::ConfigurableStorage.configure do |config|
          config[:default] = {
            cache: cache_storage,
            store: store_storage
          }
        end

        [cache_storage, store_storage]
      end

      def test_raises_storage_not_configured
        setup_no_storage

        assert_raises Shrine::Plugins::ConfigurableStorage::StorageNotConfigured do
          cache_uploader = MyUploader.new(:cache)
          cache_uploader.upload(StringIO.new('content'))
        end
      end

      def test_shrine_uses_configured_storage
        cache_store, = setup_foo_storage

        cache_uploader = MyUploader.new(:cache)

        cached_file = cache_uploader.upload(StringIO.new('content'))
        assert cache_store.exists?(cached_file.data['id']),
               'Expected file to be uploaded to foo cache store'
      end

      def test_shrine_uses_configured_storage_for_processing
        _, store = setup_foo_storage

        cache_uploader = MyUploader.new(:cache)
        cached_file = cache_uploader.upload(StringIO.new('content'))

        process_uploader = MyUploader.new(:store)
        processed_file = process_uploader.upload(cached_file, action: :store)
        assert store.exists?(processed_file.data['id']),
               'Expected file to be processed to foo store'
      end

      def test_shrine_uses_default_storage_group
        cache_store, = setup_default_storage

        cache_uploader = OtherUploader.new(:cache)

        cached_file = cache_uploader.upload(StringIO.new('content'))
        assert cache_store.exists?(cached_file.data['id']),
               'Expected file to be uploaded to default cache store'
      end
    end
  end
end
