#
# push.rb
#

module Puppet::Parser::Functions
  newfunction(:push, :type => :rvalue, :doc => <<-ENDHEREDOC) do |args|
This function joins two arrays together.

*Examples:*

    push(['a','b','c'], ['d'])

Would result in: ['a','b','c','d']
    ENDHEREDOC

    if args.length != 2
       raise Puppet::ParseError, ("merge(): wrong number of arguments (#{args.length}; must be  2)")
    end
    a1 = args[0]
    a2 = args[1]

    args.each do |arg|
      unless arg.is_a?(Array)
        raise(Puppet::ParseError, 'push(): Arguments must be array')
      end
    end
    a1.push(*a2)
  end
end

# vim: set ts=2 sw=2 et :

