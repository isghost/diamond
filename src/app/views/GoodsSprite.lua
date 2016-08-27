local GoodsRes = {}
local ACTION_TAG_1 = 110

local GoodsSprite = class("Goods",function(type_,level,status,boxX,boxY)
	assert(type,"create Goods type param is nil ")
	level = level or math.random(1,3)
	local sprite = display.newSprite(GoodsRes[type_][level])
	sprite.boxX = boxX or 1
	sprite.boxY = boxY or 1
	sprite.status = status or -1
	sprite.type = type_
	sprite.level = level 
	return sprite 
end)

--每个sprite的位置是不会发生变化，而且是相同的
--action产生的移动除外
GoodsSprite.fixedPosition = nil 

function GoodsSprite:ctor(...)
	self:setAnchorPoint(cc.p(0.5,0.5))
	if self.fixedPosition then
		self:setPosition(self.fixedPosition.x,self.fixedPosition.y)
	end
end

function GoodsSprite:setFixedPosition(x,y)
	if not y then
		self.fixedPosition = x 
	else
		self.fixedPosition = cc.p(x,y)
	end
	return self 
end

function GoodsSprite:getFixedPosition()
	return self.fixedPosition
end

function GoodsSprite:getType()
	return self.type 
end
function GoodsSprite:getLevel()
	return self.level 
end

function GoodsSprite:setStatus(status,x,y)
	self.status = status 
	self:reset()
	if status == self.STATUS_STANDY then return end
	self:setOpacity(180)

	local action1 = nil 
	if x == 0 and y == 0 then
		action1 = cc.ScaleBy:create(0.3,1.2)
	else
		action1 = cc.MoveBy:create(0.3,cc.p(x,y))
	end
	local action2 = cc.RepeatForever:create(cc.Sequence:create(action1,action1:reverse()))

	action2:setTag(ACTION_TAG_1)
	self:runAction(action2)
	return self 
end

function GoodsSprite:reset()
	self:stopActionByTag(ACTION_TAG_1)
	if self.fixedPosition then
		self:setPosition(self.fixedPosition.x,self.fixedPosition.y)
	end
	self:setOpacity(250)
	self:setScale(1.0)
end
function GoodsSprite:getStatus()
	return self.status 
end


GoodsSprite.TYPE_PLANT = "PLANT"
GoodsSprite.TYPE_FLOWER = "FLOWER"
GoodsSprite.STATUS_STANDY = "standy"
GoodsSprite.STATUS_MOVE = "move"

GoodsRes[GoodsSprite.TYPE_PLANT] = {}

for i = 1,12 do 
	GoodsRes[GoodsSprite.TYPE_PLANT][i] = "icon/dia_"..i..".png"
end

GoodsRes[GoodsSprite.TYPE_FLOWER] = {
	"botamon.png"
}

return GoodsSprite
