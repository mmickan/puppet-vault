module Puppet::Parser::Functions
  newfunction(:is_absolute_path, :type => :rvalue, :doc => <<-EOS
Returns true if the variable passed to this function is an absolute path.
EOS
  ) do |arguments|

    raise(Puppet::ParseError, "is_absolute_path(): Wrong number of arguments " +
      "given (#{arguments.size} for 1)") if arguments.size < 1

    arg = arguments[0]

    if arg.is_a?(String) and arg =~ %r!^/! then
      return true
    else
      return false
    end
  end
end

# vim: set ts=2 sw=2 et :
