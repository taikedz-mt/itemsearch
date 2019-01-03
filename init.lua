-- (C) 2016 Tai "DuCake" Kedzierski

-- This program is Free Software, you can modify and redistribute it as long as
-- that you provide the same rights to whomever you provide the original or
-- modified version of the software to, and provide the source to whomever you
-- distribute the software to.
-- Released under the terms of the GPLv3

local itemlist = {}

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
    description = "Search for an item name using substring to match on. If multiple strings are provided, itemstring must contain all substrings.",
    parameters = "<substrings ...>",
	func = function(player,paramlist)

		local paramt = tokenize(paramlist)

        if #paramt <= 0 then
            minetest.chat_send_player("No substrings to search with.")
        end

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

local function identify_inventory(user)
    local inventory = user:get_inventory()
    local col = 0
    local row = 1
    for idx,x in pairs(inventory:get_list("main") ) do
        minetest.chat_send_player(user:get_player_name(), row..":"..(col+1).." -> "..x:get_name() )
        col = (col+1) % 8
        if col == 0 then row = row+1 end
    end
    return 0
end

minetest.register_chatcommand("listinventory",{
    privs = "itemsearch",
    description = "List item strings of each item in inventory",
    func = function(player,paramlist)
        if paramlist ~= "" then
            local target_player = minetest.get_player_by_name(paramlist)
            if target_player then
                identify_inventory(target_player)
            else
                minetest.chat_send_player(player, "Could not get player "..paramlist)
            end
        else
            identify_inventory(minetest.get_player_by_name(player) )
        end
    end,
})
