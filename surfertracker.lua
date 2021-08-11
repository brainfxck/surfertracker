
CreateClientConVar("Vulcan_SurfingTracker", 0, true, false)
CreateClientConVar("Vulcan_SurfingTracker_PosDist", 500, true, false)
CreateClientConVar("Vulcan_SurfingTracker_RecurrencyDist", 500, true, false)
CreateClientConVar("Vulcan_SurfingTracker_PathsLength", 10, true, false)
CreateClientConVar("Vulcan_SurfingTracker_Player", "", true, false)
CreateClientConVar("Vulcan_SurfingTracker_ShowAllPaths", 0, true, false)
CreateClientConVar("Vulcan_SurfingTracker_ShowRecurrentPaths", 1, true, false)
CreateClientConVar("Vulcan_SurfingTracker_Percentage", 5, true, false)

Vulcan.TempSurfingPos = {}
Vulcan.SurfingPaths = {}
Vulcan.RecurrentPaths = {}
Vulcan.PathsNumber = {}

local function CheckForReccurency(tbl_pos, tbl_rc_paths, ply)
	-- print("checking for recurrency...", tbl_pos)
	for k,v in pairs(tbl_rc_paths) do
		for a,b in pairs(k) do
			if b:DistToSqr(tbl_pos[a]) < GetConVarNumber("Vulcan_SurfingTracker_RecurrencyDist")*GetConVarNumber("Vulcan_SurfingTracker_RecurrencyDist") then
				-- print("recurrency", a, b, tbl_pos[a], k, tbl_pos)
				if a == GetConVarNumber("Vulcan_SurfingTracker_PathsLength")*2 then 
				-- print("recurrent path added!")
					tbl_rc_paths[k] = tbl_rc_paths[k] + 1
					Vulcan.PathsNumber[ply] = Vulcan.PathsNumber[ply] + 1
					return true
				end
			else
				break
			end
		end
	end
	return false
end


hook.Add("Think", "surf_tracker", function() -- recording players positions


if GetConVarNumber("Vulcan_SurfingTracker") != 1 then return end

	for k,v in pairs(player.GetAll()) do

		if not validation_with_localplayer(v) then return end -- shortcut
		
		if v:GetVelocity():LengthSqr() > 1000000 then 
			

			if not Vulcan.TempSurfingPos[v] then
				Vulcan.TempSurfingPos[v] = {}
				Vulcan.PathsNumber[v] = 0
			end
	
			local tbl_pos = Vulcan.TempSurfingPos[v] -- easier to access this way

			if #tbl_pos > 1 then -- if there is already a pos inside the tbl then check the dist before adding a new pos
				if tbl_pos[#tbl_pos-1]:Distance(v:GetPos()) > GetConVarNumber("Vulcan_SurfingTracker_PosDist") then
					tbl_pos[#tbl_pos+1] = v:GetPos() -- adding a new pos
				end
			else
				tbl_pos[#tbl_pos+1] = v:GetPos() -- add the first pos
			end
			
			if #tbl_pos == GetConVarNumber("Vulcan_SurfingTracker_PathsLength")*2 then
				if not Vulcan.SurfingPaths[v] then
					Vulcan.SurfingPaths[v] = {}
					Vulcan.RecurrentPaths[v] = {}
				end
				local all_paths = Vulcan.SurfingPaths[v]
				all_paths[#all_paths+1] = tbl_pos
				local tbl_rc_paths = Vulcan.RecurrentPaths[v]

				
				if next(tbl_rc_paths) then
					if not CheckForReccurency(Vulcan.TempSurfingPos[v], Vulcan.RecurrentPaths[v], v) then
						-- print("unique path added!")
						tbl_rc_paths[tbl_pos] = 1
						Vulcan.PathsNumber[v] = Vulcan.PathsNumber[v] + 1
					end
				else
					-- print("first key added, no recurrency checking", tbl_pos)
					Vulcan.PathsNumber[v] = 1
					tbl_rc_paths[tbl_pos] = 1
				end

				Vulcan.TempSurfingPos[v] = {} -- cleaning the temp pos table
				-- print("caught a new path!")
				
			end

	
		else
			if Vulcan.TempSurfingPos[v] and #Vulcan.TempSurfingPos[v] > 1 and #Vulcan.TempSurfingPos[v] < GetConVarNumber("Vulcan_SurfingTracker_PathsLength")*2 then 
			if v:GetVelocity():LengthSqr() == 20.25 then return end -- theres a glitch when players are surfing while holding their props pushing themselves, the vel gets reset to 4.5 wtf
				-- print("surfing path was interrupted before the ending pos, aborting..") -- if the player dies or stops before the 20th position, dont create any path
				Vulcan.TempSurfingPos[v] = {} -- cleaning the temp pos table
			end
		end
	end



end)


hook.Add("PreDrawEffects", "drawing_paths", function()

	if GetConVarNumber("Vulcan_SurfingTracker") != 1 then return end

	local ply = Player(GetConVarNumber("Vulcan_SurfingTracker_Player"))

	if GetConVarNumber("Vulcan_SurfingTracker_ShowAllPaths") == 1 then 
		local tab2 = Vulcan.SurfingPaths[ply]
		if tab2 then
			for k,v in pairs(tab2) do
				for int = 1, #v do
					if v[int+1] then
						render.DrawLine(v[int], v[int+1], Color(255,0,0,255))
					end
				end
			end
		end
	end

	if GetConVarNumber("Vulcan_SurfingTracker_ShowRecurrentPaths") == 1 then 
		local tab = Vulcan.RecurrentPaths[ply]
		if tab then
			for a,b in pairs(tab) do
				if b/Vulcan.PathsNumber[ply]*100 >= GetConVarNumber("Vulcan_SurfingTracker_Percentage") then
					for i = 1, #a do
						if a[i+1] then
							render.DrawLine(a[i], a[i+1], Color(0,255,0, (b/Vulcan.PathsNumber[ply]*100)*10)) -- or *255*2
						end
					end
				end
			end
		end
	end

end)