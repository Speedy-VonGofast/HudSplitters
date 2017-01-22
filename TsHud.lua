-- Creating Console Variables	
	CreateClientConVar("TsHud_enabled",1,true,false)
	CreateClientConVar("TsHud_bars",1,true,false)
	CreateClientConVar("TsHud_HpAlert",0,true,false)
	CreateClientConVar("TsHud_Spacing",0,true,false)
	CreateClientConVar("TsHud_ScoreSpacing",0,true,false) 
	CreateClientConVar("TsHud_FadeDelay",2,true,false)
	CreateClientConVar("TsHud_Ammo",1,true,false)
	CreateClientConVar("TsHud_MaxHP",100,true,false)
	CreateClientConVar("TsHud_MaxAP",100,true,false)
	CreateClientConVar("TsHud_DamageOverlay",1,true,false)
	CreateClientConVar("TsHud_PreviewMode",0,false,false)
	CreateClientConVar("TsHud_HorizontalAlign",0,true,false)
	
 
-- Setting up textures
	local HealthFrame = surface.GetTextureID("VGUI/TsHud/Frames")
	local HealthFrame2 = surface.GetTextureID("VGUI/TsHud/Frames2")
	local HealthBar = surface.GetTextureID("VGUI/TsHud/Bars")
	local HealthBarLost = surface.GetTextureID("VGUI/TsHud/BarsLost")

	local ArmorFrame = surface.GetTextureID("VGUI/TsHud/Frames") 
	local ArmorFrame2 = surface.GetTextureID("VGUI/TsHud/Frames2") 
	local ArmorBar = surface.GetTextureID("VGUI/TsHud/Bars")
	local ArmorBarLost = surface.GetTextureID("VGUI/TsHud/BarsLost")
	local ArmorAlert = surface.GetTextureID("VGUI/TsHud/BarsAlert")
	
	local Damage = surface.GetTextureID("VGUI/TsHud/Damage")
		
	local AmmoIcon = surface.GetTextureID("VGUI/TsHud/AmmoIcons/ammo_1")

-- Startup alpha
	local HpAlpha = 600
	local ApAlpha = 600
	
	local AlertHp = 0
	
	local HudMinAlpha = 255
	local HpMinAlpha = 0
	
	local DamageAlpha = 0
	local DamageMinAlpha = 0

-- Initial variables
	local HNextTimer = 0
	local ANextTimer = 0

	local HudFadeDelay = GetConVarNumber("TsHud_FadeDelay")


	local ArmorDamageDelay = 0
	local ArmorDamageValue = 100

	local HealthDamageDelay = 0
	local HealthDamageValue = 100

	local NextTimer = 0
	

surface.CreateFont( "EuroCaps", {
		font = "Euro Caps", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
		size = 0.0555555555555556 * ScrH(), -- 60
		weight = 500,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )	

print("hud is running")

hook.Add("HUDPaint","HudSplitters",function()
	if (GetConVarNumber("TsHud_enabled")==1) then
		
		local Spacing = GetConVarNumber("TsHud_Spacing")
		local ScoreSpacing = 0
	
		local player = LocalPlayer()
		local Weapon = player:GetActiveWeapon()
	
		

		local DispScore = 0
		local HideScore = 255
			
		local MaxHP = GetConVarNumber("TsHud_MaxHP")  
		local MaxAP = GetConVarNumber("TsHud_MaxAP")

			
		local ses_enable = GetConVarNumber("ses_enable")  
		local TsHud_HpAlert = GetConVarNumber("TsHud_HpAlert")  
		local AmmoDisplayEnable = GetConVarNumber("TsHud_Ammo")
			
		if !ses_enable then
			local ses_enable = 0
		end 
					
		
		-- Lost health transition
			if (!player.LostHealth) then
				player.LostHealth = 0
			end
			
			if (player:Health() and player.LostHealth) then
				if (player.LostHealth > player:Health()) and HealthFreeze == 0 then
					player.LostHealth = math.Clamp(player.LostHealth-RealFrameTime()*75,0,MaxHP)
					if (player.LostHealth < player:Health()) then
						player.LostHealth = player:Health() 
					end
				elseif (player.LostHealth < player:Health()) then
					if ses_enable == 1 then
						player.LostHealth = player.DispHealth
					else
						player.LostHealth = player:Health()
					end
				end
			end
			
			if (!player.DispHealth) then
				player.DispHealth = 0
			end
			
			if (player:Health() and player.DispHealth) then
				if (player.DispHealth < player:Health()) then
					player.DispHealth = player.DispHealth+RealFrameTime()*35
					if (player.DispHealth > player:Health()) then
						player.DispHealth = player:Health()
					elseif(player:Health() >= (player.DispHealth + 15)) then
						player.DispHealth = player.DispHealth+RealFrameTime()*100
					end
				
				elseif (player.DispHealth > player:Health()) then
					player.DispHealth = player:Health()	
				end
			end
		
		
			if player.LostHealth == player:Health() then
				HealthFreeze = 1
				HealthDamageDelay = CurTime()+0.4
				HealthDamageValue = player:Health()
			end
		
			--if HealthDamageValue ~= player:Health() then
			--	HealthFreeze = 1
			--	HealthDamageValue = player:Health()
			--	HealthDamageDelay = CurTime()+0.4
			--end
			
			if HealthDamageDelay < CurTime() or player:Health() <= 0 then
				HealthFreeze = 0
			end
		
		-- Lost armor transition
			if (!player.LostArmor) then
				player.LostArmor = 0 
			end
			
			if (player:Armor() and player.LostArmor) then
				if (player.LostArmor > player:Armor()) and ArmorFreeze == 0 then
					player.LostArmor = math.Clamp(player.LostArmor-RealFrameTime()*75,0,100)
					if (player.LostArmor < player:Armor()) then
						player.LostArmor = player:Armor() 
					end
				elseif (player.LostArmor < player:Armor()) then
				
					if ses_enable == 1 then
						player.LostArmor = player.DispArmor
					else
						player.LostArmor = player:Armor()
					end
				end
			end
			
			if (!player.DispArmor) then
				player.DispArmor = 100
			end
			
			if (player:Armor() and player.DispArmor) then
				if (player.DispArmor < player:Armor()) then
					player.DispArmor = player.DispArmor+RealFrameTime()*35
					if (player.DispArmor > player:Armor()) then
						player.DispArmor = player:Armor()
					elseif (player:Armor() >= (player.DispArmor+15)) then
						player.DispArmor = player.DispArmor+RealFrameTime()*100
					end
				
				elseif (player.DispArmor > player:Armor()) then
					player.DispArmor = player:Armor()	
				end
			end
			
			if player.LostArmor == player:Armor() then
				ArmorFreeze = 1
				ArmorDamageDelay = CurTime()+0.4
				ArmorDamageValue = player:Armor()
			end
			
			--if ArmorDamageValue ~= player:Armor() then
			--	ArmorFreeze = 1
			--	ArmorDamageValue = player:Armor()
			--	ArmorDamageDelay = CurTime()+0.4
			--end
			
			if ArmorDamageDelay < CurTime() or player:Armor() <= 0 then
				ArmorFreeze = 0
			end
		
		-- Dynamic Hud Alpha
			HpAlpha = math.Clamp(HpAlpha -RealFrameTime()*300,HudMinAlpha-HpMinAlpha,1000)
			ApAlpha = math.Clamp(ApAlpha -RealFrameTime()*300,HudMinAlpha,1000)
			
			player.HealthNum = player:Health()
			player.ArmorNum = player:Armor()
			
			CurrentTimer = CurTime()
			
			
			if CurrentTimer < HNextTimer then
				player.HealthNumNew = player:Health()
			end
			
			if CurrentTimer < ANextTimer then
				player.ArmorNumNew = player:Armor()
			end
			
			
			if (player.HealthNum ~= player.HealthNumNew) then
				HpAlpha = 250
				HNextTimer = CurTime()+0.1
			end
			
			if (player.ArmorNum ~= player.ArmorNumNew) then
				ApAlpha = 250
				ANextTimer = CurTime()+0.1
			end
			
			if ses_enable == 1 then
				if player:Armor() < 100 then
					HudFadeDelay = CurTime()+ GetConVarNumber("TsHud_FadeDelay")
				end
			end
			if (player.HealthNum ~= player.HealthNumNew) or (player.ArmorNum ~= player.ArmorNumNew) then
				HudMinAlpha = 255
				
				HudFadeDelay = CurTime()+ GetConVarNumber("TsHud_FadeDelay")
				NextTimer = CurTime()+0.1
			end
			
			-- Low health alert
				if TsHud_HpAlert == 1 then
					if player:Health() <= 20 then
						HpMinAlpha = 255
						HpAlpha = 0
						AlertHp = math.Clamp(AlertHp -RealFrameTime()*1000,HudMinAlpha-HpMinAlpha,1000)
						if AlertHp < 50 then 
							AlertHp = 400
						end
					else
						AlertHp = 0
						HpMinAlpha = 0
					end
				end
			
			if (GetConVarNumber("TsHud_Previewmode")==0) then
	 			if HudFadeDelay < CurTime() then
					HudMinAlpha = 0
				end
			else
				HudMinAlpha = 255
			end
		
		-- Damage overlay alpha
			if(GetConVarNumber("TsHud_DamageOverlay")==1) then

				-- Fill missing variables at start to avoid error
					if (!player.HealthNum) then
						player.HealthNum = 100
					end

					if (!player.HealthNumNew) then
						player.HealthNumNew = 100
					end

					if (!player.ArmorNum) then
						player.ArmorNum = 0
					end

					if (!player.ArmorNumNew) then
						player.ArmorNumNew = 0
					end

				HealthDifference = math.Clamp((player.HealthNumNew - player.HealthNum) + (player.ArmorNumNew - player.ArmorNum),0,500)
				
				if player:Health() > 50 then
					DamageAlpha = (DamageAlpha + HealthDifference*10)
					
				elseif player:Health() <= 50 then
					DamageAlpha = (DamageAlpha + HealthDifference*20)
				elseif player:Health() <= 25 then
					DamageAlpha = (DamageAlpha + HealthDifference*60)
				end
				
				if (player.HealthNum ~= player.HealthNumNew) and player:Health() <= 50 then
					DamageMinAlpha = 100
				end
				
				DamageMinAlpha = 0
				DamageAlpha = math.Clamp(DamageAlpha - RealFrameTime()*75,DamageMinAlpha,270)
					
		
				--Damage overlay
					surface.SetTexture(Damage)
						surface.SetDrawColor(Color(255,255,255,DamageAlpha))
						surface.DrawTexturedRect(0,0,ScrW(),ScrH())
			end
		
		-- HUD drawing
			if(GetConVarNumber("TsHud_bars")==1) then

				-- Get ScoreSpacing when the scoreboard is shown
					if player:KeyDown ( IN_SCORE ) then
							ScoreSpacing = GetConVarNumber("TsHud_ScoreSpacing")
					end		

				-- Elements position

					HudPos = (0.125 * ScrW()) + GetConVarNumber("TsHud_HorizontalAlign") --240/1920

					local BarsWidth = 1.333333333333333 * ScrH() --1440
					local BarsHeight = ScrH() -- 1080

					local SingleBarWidth = 0.3703703703703704 * ScrH() -- 400
					local SingleBarHeight = 0.6518518518518519 * ScrH() -- 704

					local ArmorScissorWidth = 0.7407407407407407 * ScrH() -- 800
					local HealthScissorWidth = 0.0520833333333333 -- 100

					local ArmorBarPercentageStartW = (HudPos + (1.018518518518519 * ScrH())) + Spacing + ScoreSpacing -- 1350
					local ArmorBarPercentageStartH = 0.8259259259259259*ScrH() -- 892
					
					local HealthBarPercentageStartW = HudPos - Spacing - ScoreSpacing -- 240
					local HealthBarPercentageStartH = 0.8259259259259259*ScrH() -- 892


				-- Show bars when held scoreboard
					local HpPos = HudPos+(0.2685185185185185 * ScrH()) - Spacing - ScoreSpacing -- 530 (HudPos + 290) 
					local ApPos = HudPos+(1.060185185185185 * ScrH()) + Spacing + ScoreSpacing -- 1385 (HudPos + 1145)
					local HeightPos = 0.8240740740740741 * ScrH()-- 890
					local OverHeightPos =  0.125 * ScrH()--135


					if player:KeyDown ( IN_SCORE ) then
						draw.SimpleTextOutlined(player:Health(), "EuroCaps", HpPos, HeightPos, Color(255,0,0,255), 2, 0, 2, Color(0,0,0,255))
						draw.SimpleTextOutlined(player:Armor(), "EuroCaps", ApPos, HeightPos, Color(44,81,204,255), 3, 0, 2, Color(0,0,0,255))
						DispScore = 1000
						HideScore = 0
					end		 
					
				-- Armor Frame
					surface.SetTexture(ArmorFrame)
						surface.SetDrawColor(Color(255,255,255,DispScore)) 
						render.SetScissorRect(HudPos+ArmorScissorWidth+Spacing+ScoreSpacing,0,HudPos+1400+Spacing+ScoreSpacing,1440,true)
						surface.DrawTexturedRect(HudPos + Spacing + ScoreSpacing,0,BarsWidth,BarsHeight)
						
					surface.SetTexture(ArmorFrame2)
						surface.SetDrawColor(Color(255,255,255,(ApAlpha)/2))
						render.SetScissorRect(HudPos+ArmorScissorWidth+Spacing+ScoreSpacing,0,HudPos+1400+Spacing+ScoreSpacing,1440,true)
						surface.DrawTexturedRect(HudPos + Spacing + ScoreSpacing,0,BarsWidth,BarsHeight)
				
				-- Health Frame
					surface.SetTexture(HealthFrame)  
						surface.SetDrawColor(Color(255,255,255,DispScore)) 
						render.SetScissorRect(HudPos+HealthScissorWidth-Spacing-ScoreSpacing,0,HudPos+SingleBarWidth-Spacing-ScoreSpacing,1440,true)
						surface.DrawTexturedRect(HudPos - Spacing - ScoreSpacing,0,BarsWidth,BarsHeight)
					
					surface.SetTexture(HealthFrame2)
						surface.SetDrawColor(Color(255,255,255,(HpAlpha+AlertHp)/2))
						render.SetScissorRect(HudPos+HealthScissorWidth-Spacing-ScoreSpacing,0,HudPos+SingleBarWidth-Spacing-ScoreSpacing,1440,true)
						surface.DrawTexturedRect(HudPos - Spacing - ScoreSpacing,0,BarsWidth,BarsHeight)
						
				-- Health Bar
					surface.SetTexture(HealthBar)
						surface.SetDrawColor(Color(255,255,255,HpAlpha+DispScore+AlertHp))
						render.SetScissorRect(HealthBarPercentageStartW,HealthBarPercentageStartH,HealthBarPercentageStartW+SingleBarWidth,HealthBarPercentageStartH-math.Clamp(player.DispHealth/MaxHP*SingleBarHeight,0,1000),true)
						surface.DrawTexturedRect(HudPos - Spacing - ScoreSpacing,0,BarsWidth,BarsHeight)
						render.SetScissorRect(HealthBarPercentageStartW,HealthBarPercentageStartH,HealthBarPercentageStartW+SingleBarWidth,HealthBarPercentageStartH-math.Clamp(player.DispHealth/MaxHP*SingleBarHeight,0,1000),false)
				
					surface.SetTexture(HealthBarLost)
						surface.SetDrawColor(Color(255,255,255,HpAlpha+DispScore+AlertHp))
						render.SetScissorRect(HealthBarPercentageStartW,HealthBarPercentageStartH-math.Clamp(player.DispHealth/MaxHP*SingleBarHeight,0,1000),HealthBarPercentageStartW+SingleBarWidth,HealthBarPercentageStartH-math.Clamp(player.LostHealth/MaxHP*SingleBarHeight,0,1000),true)
						surface.DrawTexturedRect(HudPos - Spacing - ScoreSpacing,0,BarsWidth,BarsHeight)
						render.SetScissorRect(HealthBarPercentageStartW,HealthBarPercentageStartH-math.Clamp(player.DispHealth/MaxHP*SingleBarHeight,0,1000),HealthBarPercentageStartW+SingleBarWidth,HealthBarPercentageStartH-math.Clamp(player.LostHealth/MaxHP*SingleBarHeight,0,1000),false)
				
				-- SES alert
					if player:Armor() <= 0 and ses_enable == 1 then
						ShieldAlertTransition = ShieldAlertTransition-RealFrameTime()*500
						
					elseif player:Armor() > 0 or ses_enable == 0 then
						ShieldAlertTransition = 0
					end
				
				
					surface.SetTexture(ArmorAlert)
						surface.SetDrawColor(Color(255,255,255,ShieldAlertTransition))
						render.SetScissorRect(HudPos+900+ Spacing + ScoreSpacing,0,HudPos+2000,1440,true)
						surface.DrawTexturedRect(HudPos + Spacing+ ScoreSpacing,0,BarsWidth,BarsHeight)
				
				-- Armor Bar
					surface.SetTexture(ArmorBar)
						surface.SetDrawColor(Color(255,255,255,ApAlpha+DispScore))
						render.SetScissorRect(ArmorBarPercentageStartW-100,ArmorBarPercentageStartH,ArmorBarPercentageStartW+300,ArmorBarPercentageStartH-math.Clamp(player.DispArmor/MaxAP*704,0,1000),true)
						surface.DrawTexturedRect(HudPos + Spacing + ScoreSpacing,0,BarsWidth,BarsHeight)
						render.SetScissorRect(ArmorBarPercentageStartW-100,ArmorBarPercentageStartH,ArmorBarPercentageStartW+300,ArmorBarPercentageStartH-math.Clamp(player.DispArmor/MaxAP*704,0,1000),false)
					
					surface.SetTexture(ArmorBarLost)
						surface.SetDrawColor(Color(255,255,255,ApAlpha+DispScore))
						render.SetScissorRect(ArmorBarPercentageStartW-100,ArmorBarPercentageStartH-math.Clamp(player.DispArmor/MaxAP*704,0,1000),ArmorBarPercentageStartW+270,ArmorBarPercentageStartH-math.Clamp(player.LostArmor/MaxAP*704,0,1000),true)
						surface.DrawTexturedRect(HudPos + Spacing + ScoreSpacing,0,BarsWidth,BarsHeight)
						render.SetScissorRect(ArmorBarPercentageStartW-100,ArmorBarPercentageStartH-math.Clamp(player.DispArmor/MaxAP*704,0,1000),ArmorBarPercentageStartW+270,ArmorBarPercentageStartH-math.Clamp(player.LostArmor/MaxAP*704,0,1000),false)
					
				-- Overcharge
					if player:Health() > MaxHP then
						draw.SimpleTextOutlined(("+"..(player:Health()-MaxHP)), "EuroCaps", HpPos - Spacing - ScoreSpacing, OverHeightPos, Color(255,204,0,math.Clamp(HpAlpha,0,HideScore)), 2, 0, 2, Color(0,0,0,math.Clamp(HpAlpha,0,HideScore)))
					end
					if player:Armor() > MaxAP then
						draw.SimpleTextOutlined(("+"..(player:Armor()-MaxAP)), "EuroCaps", ApPos + Spacing + ScoreSpacing, OverHeightPos, Color(0,254,31,math.Clamp(ApAlpha,0,HideScore)), 3, 0, 2, Color(0,0,0,math.Clamp(ApAlpha,0,HideScore)))
					end
			end
		
		-- Ammo
			if AmmoDisplayEnable == 1 then
				if (Weapon:IsValid()) then
					local Clip = Weapon:Clip1()
					local Ammo = player:GetAmmoCount(Weapon:GetPrimaryAmmoType())
					local SecAmmo = player:GetAmmoCount(Weapon:GetSecondaryAmmoType())
					local AmmoType = LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()
					local SecAmmoType = LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()
					local GrenadeCount = LocalPlayer():GetAmmoCount("grenade")
					
					local AmmoCountLocationW = (ScrW() - 0.1851851851851852 * ScrH()) -- 200
					local AmmoCountLocationH = (ScrH() - 0.0925925925925926 * ScrH()) -- 100
					
					local SecAmmoCountLocationW = (ScrW() - 0.1851851851851852 * ScrH())  -- 200
					local SecAmmoCountLocationH = (ScrH() - 0.162037037037037 * ScrH())	-- 175

					local AmmoIconW = 0.0296296296296296 * ScrH() -- 32
					local AmmoIconH = 0.0592592592592593 * ScrH()-- 64

					local IconSpacing = 0.0138888888888889 * ScrH() --15
					local ClipSpacing = 0.0092592592592593 * ScrH() --10

					local AmmoSpacing = 0.0509259259259259 * ScrH() --55
					
					
					if AmmoType > 0 then
						if AmmoType > 10 then
							AmmoType = 1
						end  
					 
						local AmmoIcon = surface.GetTextureID("VGUI/TsHud/AmmoIcons/ammo_"..AmmoType) 
						surface.SetTexture(AmmoIcon)
							surface.SetDrawColor(Color(255,255,255,255))
							surface.DrawTexturedRect(AmmoCountLocationW+15,AmmoCountLocationH-5,AmmoIconW,AmmoIconH)
							
						
						if Clip >= 0 then
							draw.SimpleTextOutlined(Clip, "EuroCaps", AmmoCountLocationW+ClipSpacing, AmmoCountLocationH, Color(255,255,255,255), 2, 0, 2,Color (0,0,0,255))
						end
						
						draw.SimpleTextOutlined(Ammo, "EuroCaps", AmmoCountLocationW+AmmoSpacing, AmmoCountLocationH, Color(255,255,255,255), 3, 0, 2,Color (0,0,0,255))
					end	
					
					if SecAmmoType > 0 then
						local SecAmmoIcon = surface.GetTextureID("VGUI/TsHud/AmmoIcons/ammo_"..SecAmmoType)
						surface.SetTexture(SecAmmoIcon)
							surface.SetDrawColor(Color(255,255,255,255))
							surface.DrawTexturedRect(SecAmmoCountLocationW+15,SecAmmoCountLocationH-5,AmmoIconW ,AmmoIconH)
						
						draw.SimpleTextOutlined(SecAmmo, "EuroCaps", SecAmmoCountLocationW+AmmoSpacing, SecAmmoCountLocationH, Color(255,255,255,255), 3, 0,2,Color (0,0,0,255))
					end
				end  
			end
	end
end)

-- Menu panel
	hook.Add("PopulateToolMenu", "ammolimitmenu", function()

		spawnmenu.AddToolMenuOption("Options", "HudSplitters", "HudSplitters", "HudSplitters settings", "", "", TsHudMenuPanel)

	end)

	function TsHudMenuPanel (panel)
		panel:AddControl("Checkbox", {Label = "Enable the HUD", Command = "TsHud_enabled"})
		panel:AddControl("Checkbox", {Label = "Enable preview mode (permanently show the bars)", Command = "TsHud_Previewmode"})
		panel:AddControl("Checkbox", {Label = "Enable health/armor bars", Command = "TsHud_bars"})
		panel:AddControl("Checkbox", {Label = "Enable ammo counters", Command = "TsHud_Ammo"})
		panel:AddControl("Checkbox", {Label = "Enable damage overlay (bloody screen when being hit)", Command = "TsHud_DamageOverlay"})

		panel:AddControl("Slider", {Label = "Fading time", Command = "TsHud_FadeDelay", Min = 1, Max = 10})

		panel:AddControl("Slider", {Label = "Bars spacing", Command = "TsHud_Spacing", Min = -400, Max = 400})
		panel:AddControl("Label", {Text = "Adds space to the bars from the center"})

		panel:AddControl("Slider", {Label = "Bars spacing (scoreboard)", Command = "TsHud_ScoreSpacing", Min = -400, Max = 400})
		panel:AddControl("Label", {Text = "Adds additional spacing to the bars when the scoreboard is shown"})

		
		panel:AddControl("Slider", {Label = "Horizontal align", Command = "TsHud_HorizontalAlign", Min = -400, Max = 400})
		panel:AddControl("Header", {Description = "Adjust the horizontal position of the bars in case your screen ratio is not a 16:9"})
	end

-- Hide default hud
hook.Add( "HUDShouldDraw","HideDefaultHUD1", function( szShouldDraw )
	if (GetConVarNumber("TsHud_enabled")==1) then 
	shoulddrawtable = 		
	{
		["CHudHealth"] = false,
		["CHudBattery"] = false, 
		["CHudAmmo"] = false,	
		["CHudSecondaryAmmo"] = false,
		["CHudDamageIndicator"] = false,
		["CHudSquadStatus"] = false,
	} 
		return shoulddrawtable[ szShouldDraw ]
	end
	
	
end)