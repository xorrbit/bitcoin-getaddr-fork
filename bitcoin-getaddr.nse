description = [[
Queries a Bitcoin server for a list of known Bitcoin nodes
]]

---
-- @usage
-- nmap -p 8333 --script bitcoin-getaddr <ip>
--
-- @output
-- PORT     STATE SERVICE
-- 8333/tcp open  unknown
-- | bitcoin-getaddr: 
-- |   ip                    timestamp
-- |   10.10.10.10:8333      11/09/11 17:38:00
-- |   10.10.10.11:8333      11/09/11 17:42:39
-- |   10.10.10.12:8333      11/09/11 19:34:07
-- |   10.10.10.13:8333      11/09/11 17:37:45
-- |_  10.10.10.14:8333      11/09/11 17:37:12

author = "Patrik Karlsson"
license = "Same as Nmap--See http://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

require 'shortport'
require 'bitcoin'
require 'tab'

--
-- Version 0.1
-- 
-- Created 11/09/2011 - v0.1 - created by Patrik Karlsson <patrik@cqure.net>
--

portrule = shortport.port_or_service(8333, "bitcoin", "tcp" )

action = function(host, port)
	
	local bcoin = bitcoin.Helper:new(host, port, { timeout = 10000 })
	local status = bcoin:connect()
	
	if ( not(status) ) then
		return "\n  ERROR: Failed to connect to server"
	end
	
	local status, ver = bcoin:exchVersion()
	if ( not(status) ) then
		return "\n  ERROR: Failed to extract version information"
	end
	
	local status, nodes = bcoin:getNodes()
	if ( not(status) ) then
		return "\n  ERROR: Failed to extract version information"
	end
	bcoin:close()

	local response = tab.new(2)
	tab.addrow(response, "ip", "timestamp")

	for _, node in ipairs(nodes.addresses) do
		tab.addrow(response, ("%s:%d"):format(node.address.host, node.address.port), os.date("%x %X", node.ts))
	end

	return stdnse.format_output(true, tab.dump(response) )
end

