#!/usr/bin/env ruby

require 'erb'
require 'fileutils'
require 'optparse'
require 'ostruct'
require 'yaml'

options = {
  :manifest => 'manifest.yaml'
}

OptionParser.new do |parser|
  parser.banner = 'Usage: install.rb [OPTIONS]'
  parser.on('-m', '--manifest [PATH]', 'The manifest file to use (default: ./manifest.yaml)')
  parser.on('-d', '--dry_run', 'Activate "dry run" or "debug" mode')
end.parse!(into: options)

if options[:dry_run]
  def debug(message)
    print "[DEBUG] %s\n" % message
  end

  def execute(message)
    debug 'Executing operation: ' + message
  end
else
  def debug(_) = nil

  def execute(_)
    yield
  end
end

def FileUtils.cp_r_merge(src, dest)
  if File.directory?(src) && File.directory?(dest)
    src = File.join(src, '.')
  end
  FileUtils.cp_r(src, dest)
end

debug 'Loading manifest: %s' % options[:manifest]
manifest = YAML.load_file(options[:manifest])
debug 'Manifest: %p' % manifest

for package in manifest['packages'] do
  debug 'Installing configuration package: %s' % package['name']
  source = File.expand_path(package['source'])
  # Destination is hardcoded for now, but I'll probably need Windows support soon-ish.
  destination = File.expand_path(package['dest']['macos'])

  debug 'Paths: %s -> %s' % [source, destination]
  if !Dir.exist?(destination)
    execute 'Creating destination folder: %s' % destination do
      Dir.mkdir(destination)
    end
  end

  package['copy']&.each do |copy|
    copy_source = File.join(source, copy)
    copy_destination = File.join(destination, copy)
    execute 'Copying file/directory %s to %s' % [copy_source, copy_destination] do
      FileUtils.cp_r_merge(copy_source, destination)
    end
  end

  package['template']&.each do |template|
    # Only ERB templates are available for now - might add more in the future?
    template_source = File.join(source, template)
    template_destination = File.join(destination, template).delete_suffix('.erb')
    vars = {
      :destination => destination,
      :source => source,
      :template => template
    }
    bindings = OpenStruct.new(vars).instance_eval { binding }
    execute 'Templating and copying file %s to %s, with bindings: %p' % [template_source, template_destination, vars] do
      template_string = IO.read(template_source)
      template_obj = ERB.new(template_string)
      template_result = template_obj.result(bindings)
      IO.write(template_destination, template_result, mode: 'w')
    end
  end
end
