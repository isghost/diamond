local GoodsBase = class("GoodsBase")
GoodsBase.level = {1,2,3,4,5}
GoodsBase.FLOWER = "PLANT"
GoodsBase.GRASS = "GRASS"
function GoodsBase:ctor(type_,level,boxX,boxY,status)
	self.type = type_
	self.level = level or 1
	self.boxX = boxX or 1
	self.boxY = boxY or 1
	self.status = status 
end

function GoodsBase:setType(type_)
	self.type = type_
	return self
end
function GoodsBase:getType()
	return self.type 
end

function GoodsBase:setLevel(level)
	self.level = level 
	return self 
end
function GoodsBase:getLevel(level)
	return self.level 
end

function GoodsBase:setBoxPosition(boxX,boxY)
	self.boxX = boxX or self.boxX
	self.boxY = boxY or self.boxY
	return self 
end
function GoodsBase:getBoxPosition()
	return self.boxX,self.boxY
end

function GoodsBase:setStatus(status)
	self.status = status 
	return self 
end
function GoodsBase:getStatus()
	return self.status 
end