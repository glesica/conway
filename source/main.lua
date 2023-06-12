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

local size <const> = 8
local width <const> = 50
local height <const> = 30

local cellStates = table.create(width * height, 0)
local nextStates = table.create(width * height, 0)

-- TODO: Intelligently wrap col and row for update/get state
-- TODO: Use ints for states so we can just add them with no logic

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
	if row > width then
		row -= height
	end
	
	nextStates[(row-1)*width+(col-1)+1] = state
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
	if row > width then
		row -= height
	end
	
	return cellStates[(row-1)*width+(col-1)+1]
end

function getNeighborCount(col, row)
	local count = 0
	for r = row - 1, row + 1, 1 do
		for c = col - 1, col + 1, 1 do
			if getState(c, r) then
				count += 1
			end
		end
	end
	
	if getState(col, row) then
		count -= 1
	end
	
	return count
end

function updateStates()
	for row = 1, height, 1 do
		for col = 1, width, 1 do
			local state = getState(col, row)
			local count = getNeighborCount(col, row)
			if state then
				if count == 2 or count == 3 then
					updateState(col, row, true)
				else
					updateState(col, row, false)
				end
			else
				if count == 3 then
					updateState(col, row, true)
				else
					updateState(col, row, false)
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
			if state then
				gfx.fillRect((col - 1)*size, (row - 1)*size, size, size)
			else
				gfx.drawRect((col - 1)*size, (row - 1)*size, size, size)
			end
		end
	end
end

-- A function to set up our game environment.

function setup()
	gfx.clear()
	gfx.setStrokeLocation(gfx.kStrokeInside)
	gfx.setLineWidth(1)
	
	for i = 1, width * height, 1 do
		cellStates[i] = math.random() > 0.8
	end
end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

setup()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()
	gfx.clear()
	drawStates()
	
	updateStates()
	
	playdate.timer.updateTimers()
end