# frozen_string_literal: true

def find_tag(text, tag, offset = 0)
  field_value = ''
  field_len = 0

  pos = text.index(tag, offset)
  res = {}
  unless pos.nil?
    pos += tag.length
    field_len = text[pos, 4].unpack1('i')
    field_value = field_len
    field_value = text[(pos + 4), field_len] if tag.index('Name')&.positive?
    field_value = text[(pos + 4), 12] if tag == 'name'
    res = { pos: pos, value: (field_value || ''), name: tag }
  end
  res
end

def find_attribute(stream, attr_name)
  pos = stream.index(attr_name)
  return '-na-' if pos.nil?

  find_tag(stream, attr_name)
end

def find_block_by_name(stream, block_name = 'next', offset = 0)
  pos = offset
  start_pos = offset

  if block_name == 'next'
    pos = stream.index(/begin_block/, offset)
    start_pos = pos + 'begin_block'.length
  else
    pos = stream.index(/begin_block(.){8}#{block_name}/, offset)
    # start_pos=pos
    start_pos = pos + "begin_block#{block_name}".length
  end
  start_level = 0
  current_open_count = 1
  current_level = 1
  offset = start_pos
  end_pos = 0
  while current_open_count.positive?
    next_begin = stream.index(/begin_block/, offset) + 'begin_block'.length
    next_end = stream.index(/end_block/, offset) + 'end_block'.length
    # next_begin=find_field_by_tag(stream,"begin_block","byte",offset)
    # next_end=find_field_by_tag(stream,"end_block","byte",offset)

    offset = next_end

    if next_begin < next_end
      current_open_count += 1
      offset = next_begin
    else
      current_open_count -= 1
      end_pos = next_end
      offset = next_end
    end
  end
  { start: start_pos, end: end_pos, name: block_name }
end
