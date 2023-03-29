# frozen_string_literal: true
require 'byebug'

class Menu
  attr_accessor :dude, :main_menu_action, :config, :currentitem, :items

  def initialize(config)
    @config = config
    main_menu
  end

  def add_to_menu(item) = @items.push(item).size - 1

  def menu_init
    @currentitem = 0
    @main_menu_action = 0
    @items = []
    menuheader
  end

  def init_file_list(mode = '')
    menu_init
    cfg_key = :character_dir
    cfg_key = :second_character_dir if mode == 'secondary'
    @items = Dir.glob("#{config[cfg_key]}/_*").map { File.basename(_1).to_s[1..-1] }
    @items = Dir.glob("#{config[:stash_dir]}/*.stash").map { File.basename(_1).chomp(".stash") } if mode=='stash'
    @items = Dir.glob("#{config[:wp_dir]}/*.wps").map { File.basename(_1).chomp(".wps") } if mode=='wps'

    @main_menu_action = add_to_menu('return to main menu')
    choice = input_watcher
    main_menu if choice == @main_menu_action
    choice
  end

  def list_char_files(mode = '')
    choice=init_file_list(mode)
    if choice != @main_menu_action
      dude = Character.new(@items[choice], config, mode)
      if mode == "make_rich"
        money = dude.find_field_by_tag("money")
        dude.set_int_at_pos(money[:pos],2100000000)
        dude.write_char_file
      else
        dude.write_block_to_file(mode)
      end
      puts 'SUCCESS, press a key to return to main menu'
      return_watcher
    end
  end

  def list_char_files_output(stash_file, action = 'stash')
    choice=init_file_list

    if choice != @main_menu_action
      dude = Character.new(@items[choice], config)
      dude.find_main_item_block('replace', dude.load_stash_file(stash_file)) if action=='stash'
      dude.find_wp_block('replace', dude.load_wp_file(stash_file)) if action=='wps'

      puts 'SUCCESS, press a key to return to main menu'
      return_watcher
    end
  end

  def list_data_files(type = 'stash')
    choice=init_file_list(type)
    list_char_files_output(@items[choice], type)
  end

  def menuheader
    $stdout.clear_screen
    puts ''
    puts 'tq stash swapper - use at own risk'
    puts '----------------------------------'
    puts 'choose your destiny'
    puts ''
  end

  def main_menu
    menu_init
    save_main_stash = add_to_menu('save a characters main stash to a file')
    unless @config[:second_character_dir].nil?
      save_secondary_char = add_to_menu("save a Secondary char's main stash to a file")
    end
    load_item = add_to_menu('load a stash file into characters main stash(overwrites all items!)')
    unless @config[:wp_dir].nil?
      save_wps = add_to_menu('wps: save a characters waypoints to a file')
      load_wps = add_to_menu('wps: load a waypoint fle into a character')
    end
    make_rich = add_to_menu('give a charakter a shitton of money')
    exit_item = add_to_menu('GET OUT ! ')

    choice = input_watcher
    list_char_files if choice == save_main_stash
    list_char_files('secondary') if choice == save_secondary_char
    list_char_files('make_rich') if choice == make_rich
    list_char_files('save_wps') if choice == save_wps
    list_data_files('stash') if choice == load_item
    list_data_files('wps') if choice == load_wps
    exit if choice == exit_item
  end

  def return_watcher
    $stdin.getch
    main_menu
  end

  def input_watcher(choice = '')
    while choice != 'x'
      display_menu_items
      choice = $stdin.getch

      if choice == '2' || choice.ord == 66
        @currentitem += 1
        @currentitem = @items.size if @currentitem > @items.size
      end
      if choice == '8' || choice.ord == 65
        @currentitem -= 1
        @currentitem = 0 if @currentitem.negative?
      end
      return @currentitem if choice == "\r"
    end
  end

  def display_menu_items
    active = @currentitem
    menuheader
    @items.each_with_index do |item, index|
      pre = '         '
      post = '         '
      if (index) == active
        pre = "       \e[41m  "
        post = "  \e[0m       "
      end
      puts "#{pre}#{item}#{post}"
    end
  end
end
