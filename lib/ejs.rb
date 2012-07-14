require 'stringio'
# EJS (Embedded JavaScript) template compiler for Ruby
# This is a port of Underscore.js' `_.template` function:
# http://documentcloud.github.com/underscore/

module EJS
  JS_ESCAPES = {
    '\\' => '\\',
    "'" => "'",
    "\r" => "r",
    "\t" => "t",
    "\u2028" => "u2028",
    "\u2029" => "u2029"
  }

  JS_ESCAPE_PATTERN = Regexp.union(JS_ESCAPES.keys)

  class << self
    attr_accessor :evaluation_pattern
    attr_accessor :interpolation_pattern
    attr_accessor :escape_pattern

    # Compiles an EJS template to a JavaScript function. The compiled
    # function takes an optional argument, an object specifying local
    # variables in the template.  You can optionally pass the
    # `:evaluation_pattern` and `:interpolation_pattern` options to
    # `compile` if you want to specify a different tag syntax for the
    # template.
    #
    #     EJS.compile("Hello <%= name %>")
    #     # => "function(obj){...}"
    #
    def compile(source, options = {})

      next_matches = [{
          :name => "escape",
          :re => (options[:escape_pattern] || escape_pattern)
        },{
          :name => "interpolate",
          :re => (options[:interpolation_pattern] || interpolation_pattern)
        },{
          :name => "evaluate",
          :re => options[:evaluation_pattern] || evaluation_pattern
        }]
      
      compiled_str = StringIO.new
      compiled_str << "function(obj){var __p=[],print=function(){__p.push.apply(__p,arguments);};"
      compiled_str << "with(obj||{}){__p.push('"

      refresh_matches = Proc.new do |start|
        next_matches.each do |matcher|
          #only re-evaluate if we may have passed this matcher through a higher-priority one.
          next if matcher[:begin].to_i > start

          if match = source[start..-1].match(matcher[:re])
            matcher[:begin] = match.begin(0) + start
            matcher[:end] = match.end(0) + start
            matcher[:match] = match[1]
          else
            matcher[:begin] = -1
          end
        end

        #remove crufty matchers
        next_matches.reject!{|matcher| matcher[:begin].nil? || matcher[:begin] == -1}
      end

      refresh_matches.call(0)

      idx = 0
      while(idx < source.length && next_matches.length > 0) do
        next_match = next_matches.min_by{|v| v[:begin] }
        compiled_str << js_escape!(source[idx, next_match[:begin]-idx].to_s)

        case next_match[:name]
        when "escape":
          compiled_str << "',(''+#{next_match[:match]})#{escape_function},'"
        when "interpolate":
          compiled_str << "', #{next_match[:match]},'"
        when "evaluate":
          compiled_str << "'); #{next_match[:match]}; __p.push('"
        end
 
        idx = next_match[:end]
        refresh_matches.call(idx)
      end

      compiled_str << js_escape!(source[idx..-1]) << "');}return __p.join('');}"

      return compiled_str.string
    end

    # Evaluates an EJS template with the given local variables and
    # compiler options. You will need the ExecJS
    # (https://github.com/sstephenson/execjs/) library and a
    # JavaScript runtime available.
    #
    #     EJS.evaluate("Hello <%= name %>", :name => "world")
    #     # => "Hello world"
    #
    def evaluate(template, locals = {}, options = {})
      require "execjs"
      context = ExecJS.compile("var evaluate = #{compile(template, options)}")
      context.call("evaluate", locals)
    end

    protected
      def js_escape!(source)
        source.gsub!(JS_ESCAPE_PATTERN) { |match| '\\' + JS_ESCAPES[match] }
        source.gsub!("\n", "\\n',\n'")
        source
      end

      def escape_function
        ".replace(/&/g, '&amp;')" +
        ".replace(/</g, '&lt;')" +
        ".replace(/>/g, '&gt;')" +
        ".replace(/\"/g, '&quot;')" +
        ".replace(/'/g, '&#x27;')" +
        ".replace(/\\//g,'&#x2F;')"
      end
  end

  self.evaluation_pattern = /<%([\s\S]+?)%>/
  self.interpolation_pattern = /<%=([\s\S]+?)%>/
  self.escape_pattern = /<%-([\s\S]+?)%>/
end
