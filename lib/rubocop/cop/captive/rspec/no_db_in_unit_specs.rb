# frozen_string_literal: true

module RuboCop
  module Cop
    module Captive
      module RSpec
        # Do not create database records in unit tests.
        # Use `build`, `instance_double`, or stubs instead.
        class NoDbInUnitSpecs < Base
          MSG =
            "Do not hit the database in unit tests. " \
            "Use `instance_double` or `Model.new` instead. " \
            "If testing a scope, move to spec/integration."

          DEFAULT_ALLOWED_PATHS = %w[
            spec/requests spec/system spec/features spec/integration
            spec/factories spec/services spec/jobs spec/support
          ].freeze

          def_node_matcher :factory_bot_db?, <<~PATTERN
            (send (const nil? :FactoryBot) {:create :create_list :create_pair :build :build_list :build_pair :build_stubbed :build_stubbed_list} ...)
          PATTERN

          def_node_matcher :standalone_factory_bot_db?, <<~PATTERN
            (send nil? {:create :create_list :create_pair :build :build_list :build_pair :build_stubbed :build_stubbed_list} ...)
          PATTERN

          def_node_matcher :ar_create?, <<~PATTERN
            (send (const nil? _) {:create :create!} ...)
          PATTERN

          def_node_matcher :ar_save?, <<~PATTERN
            (send _ {:save :save!} ...)
          PATTERN

          def on_send(node)
            return unless unit_spec?
            return unless db_creation?(node)

            add_offense(node)
          end

          private

          def unit_spec?
            path = processed_source.path
            return false unless path&.include?("spec/")

            allowed_paths.none? { |allowed| path.include?(allowed) }
          end

          def allowed_paths
            cop_config.fetch("AllowedPaths", DEFAULT_ALLOWED_PATHS)
          end

          def db_creation?(node)
            factory_bot_db?(node) ||
              standalone_factory_bot_db?(node) ||
              ar_create?(node) ||
              ar_save?(node)
          end
        end
      end
    end
  end
end
