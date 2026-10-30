---------------------------------------------------------------
local db = ConsolePort:GetData()
---------------------------------------------------------------
local addOn, ab = ...
---------------------------------------------------------------
local FadeIn = db.UIFrameFadeIn
---------------------------------------------------------------
local Bar = ab.bar
local Lib = ab.libs.button
---------------------------------------------------------------
local Pet = CreateFrame('Button', '$parentPet', Bar, 'SecureActionButtonTemplate, SecureHandlerBaseTemplate, SecureHandlerStateTemplate')
local Button = {}

local GetPetActionCooldown = GetPetActionCooldown
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop

Bar.Pet = Pet
Pet:Hide()
Pet.Buttons = {}
Pet.showgrid = 0
Pet.locked = 0
Pet.mode = 'show'
Pet.unit = 'pet'
Pet:SetMovable(true)
Pet:SetClampedToScreen(true)
Pet:RegisterForDrag('LeftButton')
Pet:SetScript('OnDragStart', Pet.StartMoving)
Pet:SetScript('OnDragStop', Pet.StopMovingOrSizing)
Pet:SetPoint('TOPRIGHT', 0, 50)
Pet:SetSize(64, 64)

for _, event in pairs({
	'PET_BAR_UPDATE_COOLDOWN',
	'PET_BAR_UPDATE',
	'PLAYER_CONTROL_LOST',
	'PLAYER_CONTROL_GAINED',
	'PLAYER_FARSIGHT_FOCUS_CHANGED',
	'UNIT_PET',
	'UNIT_FLAGS',
	'UNIT_AURA',
	'UNIT_PORTRAIT_UPDATE',
	'PET_BAR_UPDATE',
	'PET_BAR_UPDATE_COOLDOWN',
	'PET_SPECIALIZATION_CHANGED',
}) do pcall(Pet.RegisterEvent, Pet, event) end

Pet:RegisterForClicks('AnyUp', 'AnyDown')
Pet:SetAttribute('unit', 'pet')

Pet.Portrait = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Shadow = Pet:CreateTexture(nil, 'ARTWORK')
Pet.Border = Pet:CreateTexture(nil, 'OVERLAY')

Pet.Portrait:SetAllPoints()
Pet.Border:SetAllPoints()
Pet.Shadow:SetPoint('CENTER', 0, -5)

Pet.Border:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigNormal')
--Pet.Portrait:SetMask('Interface\\Minimap\\UI-Minimap-Background')

Pet.Shadow:SetSize(82, 82)
Pet.Shadow:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\BigShadow')
Pet.Shadow:SetAlpha(0.75)

RegisterStateDriver(Pet, 'visibility', '[pet] show; hide')

function Button:OnEnter()
	if ( not self.tooltipName ) then
		return
	end
	local uber = GetCVar('UberTooltips')
	-- Pet commands are tokens, not spell IDs. Some 3.3.5 clients resolve the
	-- Follow command's numeric ID as the unrelated Word of Recall (OLD) spell.
	if ( uber == '0' or self.isToken ) then
		GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
		local bindingText = GetBindingText(GetBindingKey('BONUSACTIONBUTTON'..self:GetID()))
		if (bindingText and bindingText ~= '') then
			GameTooltip:SetText(self.tooltipName..NORMAL_FONT_COLOR_CODE..' ('..bindingText..')'..FONT_COLOR_CODE_CLOSE, 1.0, 1.0, 1.0)
		else
			GameTooltip:SetText(self.tooltipName, 1.0, 1.0, 1.0)
		end
		if ( self.tooltipSubtext ) then
			GameTooltip:AddLine(self.tooltipSubtext, 0.5, 0.5, 0.5, true)
		end
		GameTooltip:Show()
		self.UpdateTooltip = nil
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, self)
		if (GameTooltip:SetPetAction(self:GetID())) then
			self.UpdateTooltip = self.OnEnter
		else
			self.UpdateTooltip = nil
		end
	end
end

function Button:StartFlash()
	self.flashing = true
	self.flashtime = 0
end

function Button:StopFlash()
	self.flashing = false
	self.Flash:Hide()
end

function Button:OnSizeChanged(width, height)
	if self.isSquareMode then
		for _, texture in ipairs({self.NormalTexture, self.PushedTexture}) do
			texture:ClearAllPoints()
			texture:SetPoint('CENTER', self, 'CENTER', width * (4/45), height * (-2/45))
			texture:SetSize(width * (52/45), height * (51/45))
		end
		for _, texture in ipairs({self.HighlightTexture, self.CheckedTexture}) do
			texture:ClearAllPoints()
			texture:SetPoint('CENTER', self, 'CENTER', width * (1/45), 0)
			texture:SetSize(width * (46/45), height)
		end
		self.icon:ClearAllPoints()
		self.icon:SetPoint('CENTER', self, 'CENTER', 0, 0)
		self.icon:SetSize(width * (40/45), height * (40/45))
		return
	end
	local normalX, normalY = (width * (46/32)), (height * (46/32))
	self.NormalTexture:SetSize(normalX, normalY)
	self.PushedTexture:SetSize(normalX, normalY)
end


do 
	local RADIAN_FRACTION = rad( 360 / (NUM_PET_ACTION_SLOTS - 2) )
	local Mixin = db.table.mixin
	local BUTTON_SIZE = 40

	for i=1, NUM_PET_ACTION_SLOTS do
		local x, y, r = 0, 0, 60 -- xOffset, yOffset, radius
		local angle = (i+3) * RADIAN_FRACTION
		local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )

		local name = addOn..'Pet'..i
		local button = CreateFrame('CheckButton', name, Pet, 'SecureActionButtonTemplate, PetActionButtonTemplate')
		button:SetAttribute('type', 'pet')
		button:RegisterForClicks('LeftButtonUp', 'RightButtonUp', 'MiddleButtonDown', 'MiddleButtonUp')
		button:SetAttribute('action', i)
		button:SetID(i)
		button:SetScript('OnEnter', nil)
		--button.HotKey:SetAlpha(0)

		Mixin(button, ConsolePortActionButtonMixin)

		button.icon = _G[name..'Icon']
		button.roundIconPoints = {}
		for point = 1, button.icon:GetNumPoints() do
			button.roundIconPoints[point] = {button.icon:GetPoint(point)}
		end
		button.roundIconWidth, button.roundIconHeight = button.icon:GetSize()
		button.AutoCastable = _G[name..'AutoCastable']
		button.Flash = _G[name..'Flash']
		button.roundFlashTexture = button.Flash:GetTexture()
		button.Shine = _G[name..'Shine']
		button.cooldown = _G[name..'Cooldown'];
		button.roundCooldownPoints = {}
		for point = 1, button.cooldown:GetNumPoints() do
			button.roundCooldownPoints[point] = {button.cooldown:GetPoint(point)}
		end
		button.roundCooldownWidth, button.roundCooldownHeight = button.cooldown:GetSize()
		button.NormalTexture = _G[name..'NormalTexture2']

--		button.Flash:SetMask('Interface\\Minimap\\UI-Minimap-Background')
	--	button.Flash:SetAlpha(0.25)
--		button.icon:SetMask('Interface\\Minimap\\UI-Minimap-Background')
		--button.icon:SetAllPoints()

		button.AutoCastable:Hide()

		button.NormalTexture:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\PetNormal')
		button.NormalTexture:ClearAllPoints()
		button.NormalTexture:SetPoint('CENTER', 0, 0)

		button.PushedTexture = button:GetPushedTexture()
		button.HighlightTexture = button:GetHighlightTexture()
		button.CheckedTexture = button:GetCheckedTexture()

		button.PushedTexture:SetTexture('Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\PetPushed')
		button.PushedTexture:ClearAllPoints()
		button.PushedTexture:SetPoint('CENTER', 0, 0)

		button.HighlightTexture:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite')
		button.HighlightTexture:SetAllPoints()

		button.CheckedTexture:SetTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite')
		button.CheckedTexture:SetAllPoints()

--		button.cooldown:SetSwipeTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Normal')
--		button.cooldown:SetBlingTexture('Interface\\AddOns\\ConsolePort\\Textures\\Button\\Bling')

		Mixin(button, Button)

		if i > 2 then
			button:SetPoint('CENTER', ptx, -pty -8)
			button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
		else
			button.HotkeyIcon = button:CreateTexture(nil, 'BORDER')
			button.HotkeyIcon:SetSize(32, 32)
			button.HotkeyIcon:SetPoint('BOTTOM', button, 'CENTER', 0, 0)
			button.HotkeyIcon:SetTexture(db.ICONS['CP_T'.. i])
			button.HotkeyIcon:Hide()
			button:SetPoint(i == 1 and 'BOTTOMLEFT' or 'BOTTOMRIGHT', i == 1 and 4 or -4, -12)
			button:SetSize(28, 28)
		end


		Pet.Buttons[i] = button
	end
end

-- All dimensions below are local to Pet. Scaling this parent keeps the
-- portrait, buttons, spacing, hotkeys, and secure selection growth proportional.
function Pet:ApplyAppearance(cfg)
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	cfg = cfg or ab.cfg or {}
	local scale = math.max(0.5, math.min(tonumber(cfg.petRingScale) or 1, 2))
	self:SetScale(scale)
	self.isSquareMode = cfg.useSquareButtons and true or false
	local square = self.isSquareMode
	local tex = 'Interface\\AddOns\\ConsolePortBar\\Textures\\Button\\'
	local portraitSize = 64
	local buttonSize = 40
	local radius = 60
	self:SetSize(portraitSize, portraitSize)
	self.Border:ClearAllPoints()
	self.Portrait:ClearAllPoints()
	if square then
		self.Border:SetTexture(tex .. 'SquareNormal')
		self.Border:SetPoint('CENTER', self, 'CENTER', portraitSize * (4/45), portraitSize * (-2/45))
		self.Border:SetSize(portraitSize * (52/45), portraitSize * (51/45))
		self.Portrait:SetPoint('CENTER', self, 'CENTER', 0, 0)
		self.Portrait:SetSize(portraitSize * (40/45), portraitSize * (40/45))
		self.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		self.Shadow:Hide()
	else
		self.Border:SetTexture(tex .. 'BigNormal')
		self.Border:SetAllPoints(self)
		self.Portrait:SetAllPoints(self)
		self.Portrait:SetTexCoord(0, 1, 0, 1)
		self.Shadow:Show()
	end
	-- All layouts share the original positions, sizes, and selection growth.
	-- Minimal/Triple change only the individual elements' square artwork.
	for i, button in ipairs(self.Buttons) do
		button.isSquareMode = square
		button:ClearAllPoints()
		if i > 2 then
			local angle = (i + 3) * math.rad(360 / (NUM_PET_ACTION_SLOTS - 2))
			button:SetPoint('CENTER', self, 'CENTER', radius * math.cos(angle), -radius * math.sin(angle) - 8)
			button:SetAttribute('pet-normal-size', buttonSize)
			button:SetAttribute('pet-selected-size', buttonSize * 1.25)
			button:SetSize(buttonSize, buttonSize)
		else
			button:SetPoint(i == 1 and 'BOTTOMLEFT' or 'BOTTOMRIGHT', self, i == 1 and 'BOTTOMLEFT' or 'BOTTOMRIGHT', i == 1 and 4 or -4, -12)
			button:SetSize(28, 28)
		end
		button.NormalTexture:SetTexture(tex .. (square and 'SquareNormal' or 'PetNormal'))
		button.PushedTexture:SetTexture(tex .. (square and 'SquarePushed' or 'PetPushed'))
		local highlight = square and (tex .. 'SquareHilite') or 'Interface\\AddOns\\ConsolePort\\Textures\\Button\\Hilite'
		button.HighlightTexture:SetTexture(highlight)
		button.CheckedTexture:SetTexture(highlight)
		button.Flash:SetTexture(square and highlight or button.roundFlashTexture)
		button.icon:SetTexCoord(square and 0.07 or 0, square and 0.93 or 1, square and 0.07 or 0, square and 0.93 or 1)
		if not square then
			button.NormalTexture:ClearAllPoints()
			button.NormalTexture:SetPoint('CENTER', button, 'CENTER', 0, 0)
			button.PushedTexture:ClearAllPoints()
			button.PushedTexture:SetPoint('CENTER', button, 'CENTER', 0, 0)
			button.HighlightTexture:SetAllPoints(button)
			button.CheckedTexture:SetAllPoints(button)
			button.icon:ClearAllPoints()
			button.icon:SetSize(button.roundIconWidth, button.roundIconHeight)
			for _, point in ipairs(button.roundIconPoints) do button.icon:SetPoint(unpack(point)) end
		end
		button:OnSizeChanged(button:GetWidth(), button:GetHeight())
		button.cooldown:ClearAllPoints()
		if square then
			button.cooldown:SetAllPoints(button.icon)
		else
			button.cooldown:SetSize(button.roundCooldownWidth, button.roundCooldownHeight)
			for _, point in ipairs(button.roundCooldownPoints) do button.cooldown:SetPoint(unpack(point)) end
		end
	end
	self:Update()
end

Pet:HookScript('OnShow', function(self)
	self:Update()
	SetPortraitTexture(self.Portrait, 'pet')
	FadeIn(self, 0.2, 0, 1)
end)

Pet:HookScript('OnEnter', function(self)
	UnitFrame_UpdateTooltip(self)
end)

Pet:HookScript('OnLeave', function(self)
	self.UpdateTooltip = nil
	GameTooltip:Hide()
end)

Pet:SetScript('OnEvent', function(self, event, ...)
	local arg1 = ...
	if event == 'PLAYER_REGEN_ENABLED' then
		self:ApplyAppearance(ab.cfg)
	elseif event == 'PET_BAR_UPDATE' or event == 'PET_SPECIALIZATION_CHANGED' or
		(event == 'UNIT_PET' and arg1 == 'player') or
		((event == 'UNIT_FLAGS' or event == 'UNIT_AURA') and arg1 == 'pet') or
		event == 'PLAYER_CONTROL_LOST' or event == 'PLAYER_CONTROL_GAINED' or event == 'PLAYER_FARSIGHT_FOCUS_CHANGED' then
		self:Update()
	elseif event == 'PET_BAR_UPDATE_COOLDOWN' then
		self:UpdateCooldowns()
	end
	if 	( event == 'UNIT_PORTRAIT_UPDATE' and arg1 == 'pet' ) or
		( event == 'UNIT_PET' and arg1 == 'player' ) then
		SetPortraitTexture(self.Portrait, 'pet')
	end
end)

function Pet:Update()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i, petActionButton in ipairs(self.Buttons) do 
		petActionIcon = petActionButton.icon
		petAutoCastableTexture = petActionButton.AutoCastable
		petAutoCastShine = petActionButton.Shine
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)
		local icon = texture
		if isToken then icon = _G[texture] end
		icon = icon or [[Interface\AddOns\ConsolePortBar\Textures\ability-empty]]
		if self.isSquareMode then
			petActionButton.icon:SetTexture(icon)
		else
			SetPortraitToTexture(petActionButton.icon, icon)
		end
		if ( not isToken ) then
			petActionButton.tooltipName = name
		else 
			petActionButton.tooltipName = _G[name]
		end
		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext
		if ( isActive ) then
			if ( IsPetAttackAction(i) ) then
				petActionButton:StartFlash()
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5)
			else
				petActionButton:StopFlash()
				petActionButton:GetCheckedTexture():SetAlpha(1.0)
			end
			petActionButton:SetChecked(true)
		else
			petActionButton:StopFlash()
			petActionButton:SetChecked(false)
		end
		-- if ( autoCastAllowed ) then
		-- 	petAutoCastableTexture:Show()
		-- else
		-- 	petAutoCastableTexture:Hide()
		-- end
		if ( autoCastEnabled ) then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end
		if ( texture ) then
			if ( GetPetActionSlotUsable(i) ) then
				petActionIcon:SetVertexColor(1, 1, 1)
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
	self:UpdateCooldowns()
end

function Pet:UpdateCooldowns()
	for i=1, NUM_PET_ACTION_SLOTS, 1 do
		local button = Pet.Buttons[i]
		local cooldown = button.cooldown
		local start, duration, enable = GetPetActionCooldown(i)
		CooldownFrame_SetTimer(cooldown, start, duration, enable)
		
		-- Update tooltip
		if ( GameTooltip:GetOwner() == button ) then
			button:OnEnter()
		end
	end
end

function Pet:OnControlPet(hasControl)
	if hasControl then
		self.Buttons[1].HotkeyIcon:Show()
		self.Buttons[2].HotkeyIcon:Show()
	else

		self.Buttons[1].HotkeyIcon:Hide()
		self.Buttons[2].HotkeyIcon:Hide()
	end
end 

do -- Wheel setup
	Pet:Execute([[
		Bar = self
		---------------------------------------------------------------
		TARGET_PET = 'LeftButton'
		TOGGLE_MENU = 'RightButton'
		CONTROL_PET = 'MiddleButton'
		---------------------------------------------------------------
		BUTTONS = newtable()
		---------------------------------------------------------------
		KEYS = newtable()
		BINDINGS = newtable()
		---------------------------------------------------------------
		INDEX = 0
		---------------------------------------------------------------
		KEYS.UP 	= false		KEYS.W 		= false
		KEYS.LEFT 	= false		KEYS.A 		= false
		KEYS.DOWN 	= false		KEYS.S 		= false
		KEYS.RIGHT 	= false		KEYS.D 		= false
		---------------------------------------------------------------
		OnKey = [=[
			if self:IsVisible() then
				local key, down = ...
				-----------------------------
				if BUTTON then
					local size = BUTTON:GetAttribute('pet-normal-size') or 40
					BUTTON:SetWidth(size)
					BUTTON:SetHeight(size)
				end
				-----------------------------
				if down then
					if key == 'UP' then
						KEYS.DOWN = false
						KEYS.UP = true
					elseif key == 'DOWN' then
						KEYS.UP = false
						KEYS.DOWN = true
					elseif key == 'LEFT' then
						KEYS.RIGHT = false
						KEYS.LEFT = true
					elseif key == 'RIGHT' then
						KEYS.LEFT = false
						KEYS.RIGHT = true
					end
				else
					KEYS[key] = false
				end
				-----------------------------
				INDEX = 
					( KEYS.UP and KEYS.RIGHT 	) and 2 or -- Up/right
					( KEYS.DOWN and KEYS.RIGHT 	) and 4 or -- Down/right
					( KEYS.DOWN and KEYS.LEFT 	) and 6 or -- Down/left
					( KEYS.UP and KEYS.LEFT 	) and 8 or -- Up/left
					( KEYS.UP 					) and 1 or -- Up
					( KEYS.RIGHT 				) and 3 or -- Right
					( KEYS.DOWN 				) and 5 or -- Down
					( KEYS.LEFT 				) and 7 or 0 -- Left || none
				-----------------------------
				self:SetAttribute('index', INDEX)
				BUTTON = BUTTONS[INDEX]
				if BUTTON then
					local size = BUTTON:GetAttribute('pet-selected-size') or 50
					BUTTON:SetWidth(size)
					BUTTON:SetHeight(size)
				end
				-----------------------------
			end
		]=]
		SetBindingClick = [=[
			local binding, owner, ID = ...
			self:SetBindingClick(true, binding, owner, ID)
			self:SetBindingClick(true, 'CTRL-'..binding, owner, ID)
			self:SetBindingClick(true, 'SHIFT-'..binding, owner, ID)
			self:SetBindingClick(true, 'CTRL-SHIFT-'..binding, owner, ID)
		]=]
	]])

	Pet:WrapScript(Pet, 'PreClick', [[
		self:SetAttribute('type', nil)

		-- Target pet on regular click
		-----------------------------
		if button == TARGET_PET then
			if not down then
				self:SetAttribute('type', 'target')
			end
		-----------------------------

		-- Show unit menu on right click
		-----------------------------	
		elseif button == TOGGLE_MENU then
			if not down then
				self:SetAttribute('type', 'togglemenu')
			end
		-----------------------------

		-- Pet control
		-----------------------------
		elseif button == CONTROL_PET then
			-----------------------------
			-- Enable
			-----------------------------
			if down then
				for binding, keyID in pairs(BINDINGS) do
					control:Run(SetBindingClick, binding, self:GetFrameRef(keyID):GetName(), 'MiddleButton')
				end

				-- Attack / follow buttons
				-----------------------------
				local key1 = GetBindingKey('CP_T1')
				local key2 = GetBindingKey('CP_T2')

				if key1 then control:Run(SetBindingClick, key1, 'ConsolePortBarPet1', 'LeftButton') end
				if key2 then control:Run(SetBindingClick, key2, 'ConsolePortBarPet2', 'LeftButton') end
				-----------------------------

				-- Signal the insecure changes
				control:CallMethod('OnControlPet', true)
			-----------------------------
			-- Disable
			-----------------------------
			else
				if BUTTON then
					self:SetAttribute('type', 'macro')
					self:SetAttribute('macrotext', ('/click %s'):format(BUTTON:GetName()))
					local size = BUTTON:GetAttribute('pet-normal-size') or 40
					BUTTON:SetWidth(size)
					BUTTON:SetHeight(size)
					BUTTON = nil
				end
				self:ClearBindings()
				control:CallMethod('OnControlPet', false)
			end
		end
	]])

	Pet:WrapScript(Pet, 'OnHide', [[
		self:ClearBindings()
	]])

	-- Set these buttons to handle the input for the ring.
	local actionButtons = {
		[Pet.Buttons[3]] = 'UP',
		[Pet.Buttons[5]] = 'RIGHT',
		[Pet.Buttons[7]] = 'DOWN',
		[Pet.Buttons[9]] = 'LEFT',
	}

	for button, keyID in pairs(actionButtons) do
		button:SetAttribute('keyID', keyID)
		Pet:SetFrameRef(keyID, button)
		Pet:WrapScript(button, 'PreClick', [[
			self:SetAttribute('type', nil)
			if button == 'LeftButton' or button == 'RightButton' then
				self:SetAttribute('type', 'pet')
			else
				control:Run(OnKey, self:GetAttribute('keyID'), down) --barrun
			end
		]])
	end

	-- Define the inputs to control the pet ring
	local buttons = {
		['UP'] 		= {'W', 'UP'},
		['LEFT'] 	= {'A', 'LEFT'},
		['DOWN'] 	= {'S', 'DOWN'},
		['RIGHT'] 	= {'D', 'RIGHT'},
	}

	for direction, keys in pairs(buttons) do
		for _, key in pairs(keys) do
			Pet:Execute(format([[
				BINDINGS.%s = '%s'
			]], key, direction))
		end
	end

	-- Reference buttons 3-10 so they can be used like the utility ring
	for i=3, NUM_PET_ACTION_SLOTS do
		Pet:SetFrameRef('button', Pet.Buttons[i])
		Pet:Execute(format([[
			BUTTONS[%d] = self:GetFrameRef('button')
		]], i-2))
	end
end
