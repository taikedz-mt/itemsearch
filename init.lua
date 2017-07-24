-- (C) 2016 Tai "DuCake" Kedzierski

-- This program is Free Software, you can modify and redistribute it as long as
-- that you provide the same rights to whomever you provide the original or
-- modified version of the software to, and provide the source to whomever you
-- distribute the software to.
-- Released under the terms of the GPLv3

itemlist = {}

local loadup = function(rtable)
	if not rtable then return end
	for mtitem,def in pairs(rtable) do
		if not def.groups or not def.groups.not_in_creative_inventory then
			-- Use a key to avoid duplicate entries
			itemlist[mtitem] = mtitem
		end
	end
end

minetest.after(0,function()
	loadup(minetest.registered_mtitems)
	loadup(minetest.registered_tools)
	loadup(minetest.registered_items)
	loadup(minetest.registered_craftitems)
end
)

minetest.register_privilege("itemsearch","Lookup items")

local function tokenize(paramlist)
	local piterator = paramlist:gmatch("%S+")
	local paramt = {} -- parameter tokens
	while true do
		local param = piterator()
		if param ~= nil then
			paramt[#paramt+1] = param
		else
			break
		end
	end
	return paramt
end

minetest.register_chatcommand("finditem",{
	privs = "itemsearch",
	func = function(player,paramlist)

		local paramt = tokenize(paramlist)

		for _,mtitem in pairs(itemlist) do
			-- for each item ...
			local found = true

			-- see if ALL tokens are in it
			for _,param in pairs(paramt) do
				if not mtitem:find(param) then
					found = false
				end

				-- Current item fails ; next
				if not found then break end
			end
			if found then minetest.chat_send_player(player,"-> "..mtitem) end
		end
	end,
})
