A.Data.ProfileUI = {	
	DateTime = "v0 (00.00.0000)", 	-- 'v' is version (Day, Month, Year)
	[tab.name] = {					-- supports [2] (class tab), [7] (message tab) in /action
		-- Configure if [tab.name] is [2] (class tab)			
		LayoutOptions = {},		-- (optional) is table which can be used to configure layout position
		{						-- {} brackets on this level will create one row 
			RowOptions = {},	-- (optional) is table which can be used to configure this (current) row position on your layout 
			{					-- {} brackets on this level will create one element 
				key = value,	-- is itself element config 
			},
		},
		-- Configure if [tab.name] is [7] (message tab)	
		["phrase"] = {			-- ["phrase"] - This is key which is string phase which will match a message written in /party chat. MUST BE IN LOWER CASE!
			key = value,		-- is itself ["phrase"] config 
		},
	},
}