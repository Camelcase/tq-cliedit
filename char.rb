class Character
  attr_accessor :file
  attr_accessor :char_filename
  attr_accessor :config

  def initialize(filename, config, mode="")
    @config=config
    @char_filename=filename
    open_file(filename, mode)
  end

  def open_file(fn, mode="")
    puts "opening file _#{fn}/Player.chr"

    cfg_key=:character_dir
    cfg_key=:second_character_dir if mode=="secondary"

    stream = File.open("#{@config[cfg_key]}/_#{fn}/Player.chr", "rb")
    @file= stream.read
    stream.close
  end

  def write_char_file = File.open("#{config[:character_dir]}/_#{@char_filename}/Player.chr", "wb") { _1.write(@file) }
  def write_stash_file(stream, fn) = File.open("#{config[:stash_dir]}/#{fn}.stash", "wb") { _1.write(stream) }

  def write_wp_file(stream, fn) = File.open("#{config[:wp_dir]}/#{fn}.wps", "wb") { _1.write(stream) }
  def load_wp_file(fn) = File.open("#{config[:wp_dir]}/#{fn}.wps", 'rb') { |file| file.read }
  def load_stash_file(fn) = File.open("#{config[:stash_dir]}/#{fn}.stash", 'rb') { |file| file.read }

  def find_field_by_tag(tag, type="int", offset=0)
    text=@file
    field_value=""
    field_len=0

    pos= text.index(tag, offset)
    res={}
    if !pos.nil?
      pos = pos  + tag.length
      field_len = text[pos,4].unpack("i").first

      field_value=field_len if type=="int"
      field_value=text[(pos+4),field_len] if type=="txt"
      field_value=text[(pos+4),12] if type=="name"

      res={ pos: pos, value: (field_value||""), name: tag}
    end
    return res
  end

  def set_int_at_pos(pos,gold) = @file[pos,4]= [gold].pack('i')

  def write_wp_block(filename) = write_wp_file(find_wp_block, filename)

  def write_item_block(filename) = write_stash_file(find_main_item_block, filename)

  def write_block_to_file(mode)
    puts 'filename(no file extension please): '
    write_wp_block($stdin.gets.gsub!(/[^0-9A-Za-z]/, '')) if mode=='save_wps'
    write_item_block($stdin.gets.gsub!(/[^0-9A-Za-z]/, '')) if mode!='save_wps'
  end

  def find_wp_block(action="load", replacement=nil)
    begin_pos=@file.index('TeleportInfo')
    end_pos=@file.index('versionCheck', begin_pos+'TeleportInfo'.length)-1
    return block_action(begin_pos,end_pos, action, replacement) if action=='load'
    if action=="replace"
      block_action(begin_pos,end_pos, action, replacement)
      write_char_file if action=="replace"
    end
  end

  def find_main_item_block(action="load", replacement=nil)
    sack1 = find_block_by_name(@file, "tempBool",0)
    sack=block_action(sack1[:start],sack1[:end], action, replacement)
    write_char_file if action=="replace"
    return sack
  end

  def block_action(startpos, endpos, action="load", replacement)
    @file[startpos..endpos] = replacement if action=="replace"
    return @file[startpos..endpos] if action=="load"
    'success'
  end

  def indexes start=0, sub_string="baseName"
    index = @file[start..-1].index(sub_string)
    return [] unless index
    [index+start] + indexes(index+start+1,sub_string)
  end

  def find_tag(tag) = @file.index(tag)-4
end

