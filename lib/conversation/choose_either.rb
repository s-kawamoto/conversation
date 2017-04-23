module Conversation
  module_function

  def choose_either(comment = '', first_request = 'yes', second_request = 'no', unclear: nil, unexpected: nil)
    comment = "[#{first_request}|#{second_request}]:" if comment.nil? || comment.empty?
    print comment
    response = STDIN.gets.chomp

    response_check(response, first_request, second_request, unclear, unexpected)
  end

  def response_check(response, first_request, second_request, unclear, unexpected)
    first_regexp, second_regexp, common_regexp = generate_regexp(first_request, second_request)

    case response
    # when /^\s*(y|ye|yes)?\s*$/i
    when first_regexp
      return first_request
    # when /^\s*(n|no)?\s*$/i
    when second_regexp
      return second_request
    else
      if common_regexp
        case response
        when common_regexp
          if unclear == 'response'
            return response
          else
            return unclear
          end
        end
      end

      if unexpected == 'response'
        return response
      else
        return unexpected
      end
    end
  end

  def generate_regexp(first_request, second_request)
    first_ary = []
    second_ary = []
    common_ary = []
    top_st = '^\s*('
    bottom_st = ')\s*$'
    first_length = first_request.length
    second_length = second_request.length

    common_str = search_common(first_request, second_request)
    common_length = common_str.length

    for i in common_length...first_length
      first_ary << first_request[0..i]
    end
    first_ary << first_request if first_length == common_length
    first_join = first_ary.join('|')
    first_join = top_st + first_join + bottom_st

    for i in common_length...second_length
      second_ary << second_request[0..i]
    end
    second_ary << second_request if second_length == common_length
    second_join = second_ary.join('|')
    second_join = top_st + second_join + bottom_st

    for i in 0...common_length
      common_ary << common_str[0..i]
    end
    common_ary.pop if first_length == common_length || second_length == common_length
    common_join = common_ary.join('|')
    common_join = top_st + common_join + bottom_st unless common_join.empty?

    first_regexp = Regexp.new(first_join, Regexp::IGNORECASE)
    second_regexp = Regexp.new(second_join, Regexp::IGNORECASE)
    common_regexp = Regexp.new(common_join, Regexp::IGNORECASE) unless common_join.empty?

    return first_regexp, second_regexp, common_regexp
  end

  def search_common(first_request, second_request)
    first_sp = first_request.split("")
    second_sp = second_request.split("")
    min_length = first_request.length < second_request.length ? first_request.length : second_request.length
    min_length.times do |i|
      if first_sp[i] != second_sp[i]
        return first_request[0...i]
      end
    end
    return first_request[0...min_length]
  end
end
