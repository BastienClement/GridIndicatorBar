--[[
	Copyright (c) 2013 Bastien Clément

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the
	"Software"), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

if not Grid or not LibStub then
	return
end

local GridFrame = Grid:GetModule("GridFrame")
local GridIndicatorBar = GridFrame:NewModule("GridIndicatorBar")
local media = LibStub("LibSharedMedia-3.0")
local LibSmooth = LibStub("LibSmoothStatusBar-1.0", true)

local HORIZONTAL = "HORIZONTAL"
local VERTICAL   = "VERTICAL"

local settings

GridIndicatorBar.defaultDB = {
	GridIndicatorBar = {
		color       = { r = 1, g = 1, b = 1, a = 1 },
		background  = { r = 0, g = 0, b = 0, a = 0.75 },
		texture     = "Gradient",
		orientation = HORIZONTAL,
		
		width       = 30,
		height      = 6,
		offsetX     = 0,
		offsetY     = 0,
		
		smooth      = false,
		cdFill      = false
	}
}

local options = {
	type = "group",
	name = "Additional Bar",
	desc = "Options for Additional Bar indicator.",
	args = {
		["look"] = {
			type = "group",
			name = "Look",
			inline = true,
			order = 10,
			args = {
				["color"] = {
					type = "color",
					name = "Default color",
					desc = "Bar default color",
					order = 1,
					hasAlpha = true,
					get = function ()
						local color = settings.color
						return color.r, color.g, color.b, color.a
					end,
					set = function (_, r, g, b, a)
						local color = settings.color
						color.r = r
						color.g = g
						color.b = b
						color.a = a or 1
						GridFrame:WithAllFrames("UpdateBar2Colors")
					end,
				},
				["background"] = {
					type = "color",
					name = "Background color",
					desc = "Bar background color",
					order = 2,
					hasAlpha = true,
					get = function ()
						local color = settings.background
						return color.r, color.g, color.b, color.a
					end,
					set = function (_, r, g, b, a)
						local color = settings.background
						color.r = r
						color.g = g
						color.b = b
						color.a = a or 1
						GridFrame:WithAllFrames("UpdateBar2Colors")
					end,
				},
				["texture"] = {
					type = "select",
					name = "Texture",
					desc = "Texture of each additional bar",
					values = media:HashTable("statusbar"),
					dialogControl = "LSM30_Statusbar",
					order = 10,
					get = function()
						return settings.texture
					end,
					set = function(_, v)
						settings.texture = v
						local texture = media:Fetch("statusbar", v)
						GridFrame:WithAllFrames("SetBar2Texture", texture)
					end,
				},
				["orientation"] = {
					type = "range",
					name = "Orientation",
					desc = "Bar orientation",
					type = "select",
					values = { VERTICAL = "Vertical", HORIZONTAL = "Horizontal" },
					order = 11,
					get = function()
						return settings.orientation
					end,
					set = function(_, v)
						settings.orientation = v
						GridFrame:WithAllFrames("SetBar2Orientation", v)
					end,
				},
			},
		},
		["pos"] = {
			type = "group",
			name = "Position",
			inline = true,
			order = 20,
			args = {
				["width"] = {
					type = "range",
					name = "Width",
					desc = "Bar width",
					min = 1,
					max = 100,
					step = 1,
					width = "double",
					order = 10,
					get = function()
						return settings.width
					end,
					set = function(_, v)
						settings.width = v
						GridFrame:WithAllFrames("SetBar2Position")
					end,
				},
				["height"] = {
					type = "range",
					name = "Height",
					desc = "Bar height",
					min = 1,
					max = 100,
					step = 1,
					width = "double",
					order = 11,
					get = function()
						return settings.height
					end,
					set = function(_, v)
						settings.height = v
						GridFrame:WithAllFrames("SetBar2Position")
					end,
				},
				["offsetX"] = {
					type = "range",
					name = "X offset",
					desc = "Horizontal offset",
					min = -200,
					max = 200,
					step = 1,
					width = "double",
					order = 20,
					get = function()
						return settings.offsetX
					end,
					set = function(_, v)
						settings.offsetX = v
						GridFrame:WithAllFrames("SetBar2Position")
					end,
				},
				["offsetY"] = {
					type = "range",
					name = "Y offset",
					desc = "Vertical offset",
					min = -200,
					max = 200,
					step = 1,
					width = "double",
					order = 21,
					get = function()
						return settings.offsetY
					end,
					set = function(_, v)
						settings.offsetY = v
						GridFrame:WithAllFrames("SetBar2Position")
					end,
				},
			}
		},
		["fx"] = {
			type = "group",
			name = "Effects",
			inline = true,
			order = 30,
			args = {
				["cdFill"] = {
					type = "toggle",
					name = "Fill",
					desc = "Fills the bar up instead of draining it when used for cooldown display",
					order = 11,
					get = function()
						return settings.cdFill
					end,
					set = function(_, v)
						settings.cdFill = v
					end,
				},
			}
		}
	}
}

if LibSmooth then
	options.args["fx"].args["smooth"] = {
		type = "toggle",
		name = "Smooth",
		desc = "Smoothly animates the bar",
		order = 10,
		get = function()
			return settings.smooth
		end,
		set = function(_, v)
			settings.smooth = v
			GridFrame:WithAllFrames("SetBar2Smoothing", v)
		end,
	}
end

Grid.options.args["GridIndicatorBar"] = options

local indicators = GridFrame.prototype.indicators
table.insert(indicators, { type = "bar2", order = 4.5, name = "Additional Bar" })
table.insert(indicators, { type = "bar2color", order = 4.6, name = "Additional Bar Color" })

-------------------------------------------------------------------------------

function GridIndicatorBar:OnInitialize()
	GridFrame:RegisterModule("GridIndicatorBar", self)

	hooksecurefunc(GridFrame, "InitializeFrame", self.InitializeFrame)
	hooksecurefunc(GridFrame.prototype, "SetIndicator", self.SetIndicator)
	hooksecurefunc(GridFrame.prototype, "ClearIndicator", self.ClearIndicator)

	settings = GridIndicatorBar.db.profile.GridIndicatorBar
end

function GridIndicatorBar:OnEnable()
end

function GridIndicatorBar:OnDisable()
end

function GridIndicatorBar:Reset()
end

-------------------------------------------------------------------------------

local animating = false
local animated = {}
local animationFrame = CreateFrame("Frame")

local function AnimationTick()
	if #animated == 0 then	
		animating = false
		animationFrame:SetScript("OnUpdate", nil)
		return
	end
	
	for i, frame in ipairs(animated) do
		local state = frame.Bar2State
		if not state.isCooldown then
			state.animating = false
			table.remove(animated, i)
		else
			local start, duration, now = state.cooldownStart, state.cooldownDuration, GetTime()
			local val
			if settings.cdFill then
				val = now - start
			else
				val = start + duration - now
			end
			frame:SetBar2(val, state.cooldownDuration)
		end
	end
end

local function StartAnimating(frame)
	local state = frame.Bar2State
	
	if not state.isCooldown or state.animating then
		return
	end
	
	state.animating = true
	table.insert(animated, frame)
	
	if not animating then
		animating = true
		animationFrame:SetScript("OnUpdate", AnimationTick)
	end
end

-------------------------------------------------------------------------------

function GridIndicatorBar:InitializeFrame(frame)
	local texture = media:Fetch("statusbar", settings.texture)
	
	frame.Bar2State = {}
	
	frame.Bar2Holder = CreateFrame("Frame", nil, frame)
	frame.Bar2Holder:SetFrameLevel(5)
	frame.Bar2Holder:SetBackdrop({
		bgFile = "Interface\\BUTTONS\\WHITE8X8", tile = true, tileSize = 8,
		edgeFile = "Interface\\BUTTONS\\WHITE8X8", edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	frame.Bar2Holder:SetBackdropBorderColor(0, 0, 0, 1)
	frame.Bar2Holder:SetBackdropColor(
		settings.background.r,
		settings.background.g,
		settings.background.b,
		settings.background.a
	)
	frame.Bar2Holder:Hide()
	
	frame.Bar2 = CreateFrame("StatusBar", nil, frame.Bar2Holder)
	frame.Bar2:SetMinMaxValues(0, 100)
	frame.Bar2:SetValue(100)
	
	frame:SetBar2Position()
	frame:SetBar2Orientation(settings.orientation)
	frame:SetBar2Texture(texture)
	frame:SetBar2Smoothing(settings.smooth)
	frame:UpdateBar2Colors(texture)
end

function GridIndicatorBar:SetIndicator(indicator, color, text, value, maxValue, texture, start, duration, stack)
	if not self.Bar2 then
		return
	end
	
	if indicator ~= "bar2" and indicator ~= "bar2color" then
		return
	end
	
	local state = self.Bar2State
	
	if indicator == "bar2" then
		self.Bar2Holder:Show()
		state.isCooldown = false
		
		if value and maxValue then
			self:SetBar2(value, maxValue)
		elseif start and duration then
			state.cooldownStart = start
			state.cooldownDuration = duration
			state.isCooldown = true
			StartAnimating(self)
		else
			self:SetBar2(100, 100)
			state.isCooldown = false
		end
		
		if type(color) == "table" then
			state.color = color
			self:UpdateBar2Colors()
		end
	elseif indicator == "bar2color" and type(color) == "table" then
		state.overrideColor = color
		self:UpdateBar2Colors()
	end
end

function GridIndicatorBar:ClearIndicator(indicator)
	if not self.Bar2 then
		return
	end
	
	if indicator ~= "bar2" and indicator ~= "bar2color" then
		return
	end
	
	local state = self.Bar2State
	
	if indicator == "bar2" then
		state.color = nil
		state.isCooldown = false
		self.Bar2Holder:Hide()
		self:SetBar2(100, 100)
	elseif indicator == "bar2color" then
		state.overrideColor = nil
	end
	
	self:UpdateBar2Colors()
end

-------------------------------------------------------------------------------

function GridFrame.prototype:SetBar2(value, max)
	if max == nil then
		max = 100
	end

	self.Bar2:SetMinMaxValues(0, max)
	self.Bar2:SetValue(value)
end

function GridFrame.prototype:SetBar2Position()
	local width, height = settings.width, settings.height
	
	self.Bar2Holder:SetPoint("CENTER", self, "CENTER", settings.offsetX, settings.offsetY)
	self.Bar2Holder:SetWidth(width + 2)
	self.Bar2Holder:SetHeight(height + 2)
	
	self.Bar2:SetPoint("CENTER", self.Bar2Holder, "CENTER")
	self.Bar2:SetWidth(width)
	self.Bar2:SetHeight(height)
end

function GridFrame.prototype:SetBar2Orientation(orientation)
	self.Bar2:SetOrientation(orientation)
end

function GridFrame.prototype:SetBar2Texture(texture)
	self.Bar2:SetStatusBarTexture(texture)
end

function GridFrame.prototype:SetBar2Smoothing(smoothing)
	if not LibSmooth then return end
	if smoothing then
		LibSmooth:SmoothBar(self.Bar2)
	else
		LibSmooth:ResetBar(self.Bar2)
	end
end

function GridFrame.prototype:UpdateBar2Colors()
	local state = self.Bar2State
	local color
	
	if state.overrideColor then
		color = state.overrideColor
	elseif state.color then
		color = state.color
	else
		color = settings.color
	end
	
	self.Bar2Holder:SetBackdropColor(
		settings.background.r,
		settings.background.g,
		settings.background.b,
		settings.background.a
	)
	
	self.Bar2:SetStatusBarColor(
		color.r,
		color.g,
		color.b,
		color.a
	)
end
