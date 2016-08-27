local GoodsBase = import(".GoodsBase")

local Flower = class("Flower",GoodsBase)

function Flower:ctor(level,boxX,boxY,status)
	self.super.ctor(self,GoodsBase.FLOWER,level,boxX,boxY,status)
end

return Flower 