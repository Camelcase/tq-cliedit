# frozen_string_literal: true

require "./utils"
require './char'
require './menu'
require 'yaml'
require 'io/console'

config = {
  character_dir: '',
  stash_dir: '',
  second_stash_dir: '',
  wp_dir: ''
}

if ARGV[0] == 'save_config'
  File.open('config.yml', 'w') { _1.write(config.to_yaml) }
  exit
end

unless File.exist?('config.yml')
  puts "Warning ! config filöe doesnt exist. create with 'ruby tqswap.rb save_config' and edit according to your setup"
  exit
end

config = YAML.load_file('config.yml')

# list_char_files(config)
m = Menu.new(config)
