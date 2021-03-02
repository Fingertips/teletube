#!/usr/bin/env ruby
# frozen_string_literal: true

require 'net/http'
require 'json'

BASE_URI = 'https://tube.plz2.work'
RESOURCES = {
  'channel' => '/schema/v1/channel.json'
}.freeze

class Property
  attr_accessor :snake_case, :description, :data_type

  def boolean?
    data_type == 'boolean'
  end

  def dash_case
    snake_case.tr('_', '-')
  end

  def upcase
    snake_case.upcase
  end
end

def resources_path
  @resources_path ||= File.expand_path('../src/teletube/resources', __dir__)
end

def writeable_properties(_snake_case, request_path)
  url = File.join(BASE_URI, request_path)
  schema = JSON.parse(Net::HTTP.get(URI(url)))
  schema['properties'].map do |property_name, attributes|
    property = Property.new
    property.snake_case = property_name
    property.description = attributes['description']
    property.data_type = attributes['type']
    attributes['readOnly'] ? nil : property
  end.compact
end

def resource_callbacks(snake_case, request_path)
  writeable_properties(snake_case, request_path).map do |property|
    if property.boolean?
      <<~CALLBACK
        parser.on("--#{property.dash_case}", "#{property.description}") do
          context.params["#{property.snake_case}"] = JSON::Any.new(true)
        end
        parser.on("--no-#{property.dash_case}", "Opposite of --#{property.dash_case}") do
          context.params["#{property.snake_case}"] = JSON::Any.new(false)
        end
      CALLBACK
    else
      <<~CALLBACK
        parser.on("--#{property.dash_case} #{property.upcase}", "#{property.description}") do |#{property.snake_case}|
          context.params["#{property.snake_case}"] = JSON::Any.new(#{property.snake_case})
        end
      CALLBACK
    end
  end.join
end

RESOURCES.each do |snake_case, request_path|
  class_name = snake_case.split('_').map(&:capitalize).join
  callbacks = resource_callbacks(snake_case, request_path)
  callbacks = callbacks.split("\n").map { |line| "        #{line}" }.join("\n")
  code = <<~CLASS
    module Teletube
      module Resources
        class #{class_name}
          macro parse_properties(parser, context)
    #{callbacks}
          end
        end
      end
    end
  CLASS
  File.open(File.join(resources_path, "#{snake_case}.cr"), 'w', encoding: 'utf-8') do |file|
    file.puts(code)
  end
end
