-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

local size <const> = 16
local width <const> = 25
local height <const> = 12

local randomAlive <const> = 0.001
local randomDead <const> = 0.001
local initialAlive <const> = 0.25
local maxHealth <const> = 1

local stepTime <const> = 0

-- ------------
-- Game of Life
-- ------------

local cellStates = table.create(width * height, 0)
local nextStates = table.create(width * height, 0)

function setupStates()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			local index = locToIndex(col, row)
			local state = newRandomState()
			cellStates[index] = state
			nextStates[index] = cellStates[index]
		end
	end
end

-- Update the state of a single cell, where col and row are integer indexes in the
-- range [1, width] and [1, height], respectively and state is a boolean.
function updateState(col, row, state)
	if col < 1 then
		col += width
	end
	if col > width then
		col -= width
	end
	
	if row < 1 then
		row += height
	end
	if row > height then
		row -= height
	end
	
	local currentState = cellStates[(row-1)*width+(col-1)+1]
	nextStates[(row-1)*width+(col-1)+1] = math.max(currentState + state, 0)
end

function newRandomState()
	-- roll a die, if it comes up one way, the thing is dead, otherwise choose a random live state
	if math.random() < initialAlive then
		return newLiveState()
	else
		return 0
	end
end

function newLiveState()
	return math.floor(math.random() * maxHealth + 1)
end

-- Get the state of a single cell.
function getState(col, row)
	if col < 1 then
		col += width
	end
	if col > width then
		col -= width
	end
	
	if row < 1 then
		row += height
	end
	if row > height then
		row -= height
	end
	
	return cellStates[(row-1)*width+(col-1)+1]
end

function getNeighborCount(col, row)
	local count = 0
	for r = row - 1, row + 1, 1 do
		for c = col - 1, col + 1, 1 do
			if getState(c, r) > 0 then
				count += 1
			end
		end
	end
	
	if getState(col, row) > 0 then
		count -= 1
	end
	
	return count
end

function updateStates()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			local state = getState(col, row)
			local count = getNeighborCount(col, row)
			if state > 0 then
				if count == 2 or count == 3 then
					if math.random() < randomDead then
						updateState(col, row, -1)
					else
						updateState(col, row, 0)
					end
				else
					updateState(col, row, -1)
				end
			else
				if count == 3 or math.random() < randomAlive then
					updateState(col, row, newLiveState())
				else
					updateState(col, row, -1)
				end
			end
		end
	end
	
	for i = 1, #cellStates, 1 do
		cellStates[i] = nextStates[i]
	end
end

function drawStates()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			local state = getState(col, row)
			if state > 0 then
				showCell(col, row)
			else
				hideCell(col, row)
			end
		end
	end
end

-- ------------------
-- Indexing utilities
-- ------------------

-- Convert a column and row number into a linear index for looking
-- up cell characteristics.
function locToIndex(col, row)
	if col < 1 then
		col += width
	end
	if col > width then
		col -= width
	end
	
	if row < 1 then
		row += height
	end
	if row > height then
		row -= height
	end
	
	return (row-1)*width+(col-1)+1
end

-- -----------
-- Enemy cells
-- -----------

local cellImg = gfx.image.new("images/cell")
local cells = table.create(width * height, 0)

function setupCells()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			if math.random() > 0.3 then
				addCell(col, row, true)
			end
		end
	end
end

-- TODO: Tractor beam mechanic!

function updateCells()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			local cell = getCell(col, row)
			if cell ~= nil then
				if math.random() < 0.5 then
					cell:moveBy(8, 0)
				else
					cell:moveBy(-8, 0)
				end
			end
		end
	end
end

function drawCells()
end

function getCell(col, row)
	local index = locToIndex(col, row)
	return cells[index]
end

function addCell(col, row, visible)
	local cell = getCell(col, row)
	if cell ~= nil then
		return
	end
	
	cell = gfx.sprite.new(cellImg)
	local index = locToIndex(col, row)
	cells[index] = cell
	
	cell:setCenter(0, 0)
	cell:moveTo((col - 1)*size, (row - 1)*size)
	cell:setVisible(visible)
	cell:add()
end

function hideCell(col, row)
	local cell = getCell(col, row)
	cell:setVisible(false)
end

function showCell(col, row)
	local cell = getCell(col, row)
	cell:setVisible(true)
end

-- -----------
-- Player ship
-- -----------

local shipImg = gfx.image.new("images/ship")
local ship = gfx.sprite.new(shipImg)

function setupShip()
	ship:moveTo(200, playdate.display.getHeight() - 10)
	ship:add()
end

function updateShip()
	if playdate.buttonIsPressed(playdate.kButtonLeft) then
		ship:moveBy(-1, 0)
	end
	
	if playdate.buttonIsPressed(playdate.kButtonRight) then
		ship:moveBy(1, 0)
	end
end

function drawShip()
end

-- --------------
-- Game lifecycle
-- --------------

function setup()
	gfx.clear()
	-- gfx.setStrokeLocation(gfx.kStrokeInside)
	-- gfx.setLineWidth(1)
	
	setupCells()
	setupShip()
end

setup()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()
	-- updateStates()
	-- drawStates()
	
	updateCells()
	drawCells()
	
	updateShip()
	drawShip()
	
	gfx.sprite.update()
	playdate.timer.updateTimers()
end
