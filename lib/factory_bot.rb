require "set"
require "active_support"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/deprecation"
require "active_support/notifications"

require "factory_bot/internal"
require "factory_bot/definition_hierarchy"
require "factory_bot/configuration"
require "factory_bot/errors"
require "factory_bot/factory_runner"
require "factory_bot/strategy_syntax_method_registrar"
require "factory_bot/strategy_calculator"
require "factory_bot/strategy/build"
require "factory_bot/strategy/create"
require "factory_bot/strategy/attributes_for"
require "factory_bot/strategy/stub"
require "factory_bot/strategy/null"
require "factory_bot/registry"
require "factory_bot/null_factory"
require "factory_bot/null_object"
require "factory_bot/evaluation"
require "factory_bot/factory"
require "factory_bot/attribute_assigner"
require "factory_bot/evaluator"
require "factory_bot/evaluator_class_definer"
require "factory_bot/attribute"
require "factory_bot/callback"
require "factory_bot/callbacks_observer"
require "factory_bot/declaration_list"
require "factory_bot/declaration"
require "factory_bot/sequence"
require "factory_bot/attribute_list"
require "factory_bot/trait"
require "factory_bot/enum"
require "factory_bot/aliases"
require "factory_bot/definition"
require "factory_bot/definition_proxy"
require "factory_bot/syntax"
require "factory_bot/syntax_runner"
require "factory_bot/find_definitions"
require "factory_bot/reload"
require "factory_bot/decorator"
require "factory_bot/decorator/attribute_hash"
require "factory_bot/decorator/disallows_duplicates_registry"
require "factory_bot/decorator/invocation_tracker"
require "factory_bot/decorator/new_constructor"
require "factory_bot/uri_manager"
require "factory_bot/linter"
require "factory_bot/version"

module FactoryBot
  Deprecation = ActiveSupport::Deprecation.new("7.0", "factory_bot")

  mattr_accessor :use_parent_strategy, instance_accessor: false
  self.use_parent_strategy = true

  mattr_accessor :automatically_define_enum_traits, instance_accessor: false
  self.automatically_define_enum_traits = true

  mattr_accessor :sequence_setting_timeout, instance_accessor: false
  self.sequence_setting_timeout = 3

  # Look for errors in factories and (optionally) their traits.
  # Parameters:
  # factories - which factories to lint; omit for all factories
  # options:
  #   traits: true - to lint traits as well as factories
  #   strategy: :create - to specify the strategy for linting
  #   verbose: true - to include full backtraces for each linting error
  def self.lint(*args)
    options = args.extract_options!
    factories_to_lint = args[0] || FactoryBot.factories
    Linter.new(factories_to_lint, **options).lint!
  end

  # Set the starting value for ids when using the build_stubbed strategy
  #
  # @param [Integer] starting_id The new starting id value.
  def self.build_stubbed_starting_id=(starting_id)
    Strategy::Stub.next_id = starting_id - 1
  end

  class << self
    # @!method rewind_sequence(*uri_parts)
    #   Rewind an individual global or inline sequence.
    #
    #   @param [Array<Symbol>, String] uri_parts The components of the sequence URI.
    #
    #   @example Rewinding a sequence by its URI parts
    #     rewind_sequence(:factory_name, :trait_name, :sequence_name)
    #
    #   @example Rewinding a sequence by its URI string
    #     rewind_sequence("factory_name/trait_name/sequence_name")
    #
    # @!method set_sequence(*uri_parts, value)
    #   Set the sequence to a specific value, providing the new value is within
    #   the sequence set.
    #
    #   @param [Array<Symbol>, String] uri_parts The components of the sequence URI.
    #   @param [Object] value The new value for the sequence. This must be a value that is
    #     within the sequence definition. For example, you cannot set
    #     a String sequence to an Integer value.
    #
    #   @example
    #     set_sequence(:factory_name, :trait_name, :sequence_name, 450)
    #   @example
    #     set_sequence([:factory_name, :trait_name, :sequence_name], 450)
    #   @example
    #     set_sequence("factory_name/trait_name/sequence_name", 450)
    delegate :factories,
      :register_strategy,
      :rewind_sequences,
      :rewind_sequence,
      :set_sequence,
      :strategy_by_name,
      to: Internal
  end
end

FactoryBot::Internal.register_default_strategies
