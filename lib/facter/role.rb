Facter.add("role") do
  setcode do
        %x{if [ -f /etc/role ]; then cat /etc/role; fi}.chomp
  end
end
