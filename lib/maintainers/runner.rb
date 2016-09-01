# encoding: utf-8
# frozen_string_literal: true

require 'json'
require 'json-schema'

module Maintainers
  # Runner entry point
  class Runner
    def initialize(options)
      @options = options

      # for now just assume it's always MAINTAINERS
      options[:filename] ||= 'MAINTAINERS'
    end

    # Run, Lola, Run
    # @return nil
    def run
      case @options[:subcommand]
      when 'create'
        create(@options)
      when 'add'
        add(@options)
      when 'remove'
        remove(@options)
      end
    end

    def validate(maintainers)
      maintainers_schema = JSON.parse(File.read('schema/maintainers.json'))

      JSON::Validator.validate(maintainers_schema, maintainers)
    end

    def write_file(filename, maintainers)
      maintainers_json = JSON.pretty_generate(maintainers)

      if !validate(maintainers_json)
        $stderr.puts "Invalid maintainers string!"
        exit 1
      end

      File.open(filename, 'w') { |f| f.write(maintainers_json) }
    end

    def create(options)
      filename = options[:filename]
      if File.exist?(filename)
        $stderr.puts "#{filename} already exists. Remove it and then re-run this command."
        exit 1
      end

      # minimum content for a maintainers file
      maintainers = {}
      maintainers["version"] = 1
      maintainers["issues"] = options[:issues]
      maintainers["people"] = []

      write_file(filename, maintainers)
    end

    def add(options)
      filename = options[:filename]
      if !File.exist?(filename)
        $stderr.puts "No #{filename} file exists yet. You can use the 'create' subcommand to create one."
        exit 1
      end

      maintainers = JSON.load(File.read(filename))
      new_maintainer = { "github" => options[:github] }
      new_maintainer["email"] = options[:email] if options[:email]
      new_maintainer["name"]  = options[:name] if options[:name]
      index = maintainers["people"].index { |person| person["github"] == options[:github] }
      if index
        current = maintainers["people"][index]
        new_maintainer.merge! current
        maintainers["people"][index] = new_maintainer
      else
        maintainers["people"] << new_maintainer
      end

      write_file(filename, maintainers)
    end

    def remove(options)
      filename = options[:filename]
      if !File.exist?(filename)
        $stderr.puts "No #{filename} file exists yet. You can use the 'create' subcommand to create one."
        exit 1
      end

      maintainers = JSON.load(File.read(filename))
      index = maintainers["people"].index { |person| person["github"] == options[:github] }
      if index
        maintainers["people"].slice!(index)
      else
        puts "I didn't find #{options[:github]} in the file #{filename}"
      end

      write_file(filename, maintainers)
    end
  end
end
