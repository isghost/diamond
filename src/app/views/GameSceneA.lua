local GameScene = require "app.views.GameScene"
local GoodsSprite = import(".GoodsSprite")
local GameSceneA = class("GameSceneA",GameScene)
GameSceneA.RESOURCE_FILENAME = "GameScene.csb"
GameSceneA.beginHeartNum = 3
GameSceneA.heartNum = GameSceneA.beginHeartNum
GameSceneA.maxBoomCountDown = 4
GameSceneA.boomCountDown = GameSceneA.maxBoomCountDown
function GameSceneA:onCreate()
	self.super.onCreate(self)
	self.SceneAStatus = self.statusPanel:getChildByTag(166):setVisible(true)
	self.heartNumLabel = self.SceneAStatus:getChildByTag(105):setString(""..self.beginHeartNum)
	self.boomCountDownLabel = self.SceneAStatus:getChildByTag(106):setString(""..self.maxBoomCountDown)
end
function GameSceneA:stepWithSuccess(i,type_,vis,level,addLevel,box)
	self.super.stepWithSuccess(self,i, type_, vis, level, addLevel, box)
	self.heartNum = self.heartNum + addLevel - 1
	self.heartNumLabel:setString(""..self.heartNum)
	self.boomCountDown = self.maxBoomCountDown
	self.boomCountDownLabel:setString(""..self.boomCountDown)
end

function GameSceneA:stepWithFailed(i,type_,vis,level,addLevel,box)
	self.super.stepWithFailed(self,i, type_, vis, level, addLevel, box)
	self.boomCountDown = self.boomCountDown - 1
	local isBoom = false 
	if self.boomCountDown <= 0 then
		self.boomCountDown = self.maxBoomCountDown
		self.heartNum = self.heartNum - 1
		isBoom = true
	end
	self.heartNumLabel:setString(""..self.heartNum)
	self.boomCountDownLabel:setString(""..self.boomCountDown)
	if not isBoom then return end
	 local addBolt = function(k)
        local bolt = display.newSprite("bolt.png")
        bolt:setPosition(44,100)
        bolt:addTo(self.boxs[k],100)
        local action1 = cc.MoveBy:create(0.7,cc.p(0,-78))
        local action2 = cc.CallFunc:create(function()
            bolt:removeFromParent()
            end)
       bolt:runAction(cc.Sequence:create(action1,action2))

    end
	for i=1,36 do
		if self.goods[i] then
			local type_,level = self:getGoodInfoByIndex(i)
			self.goods[i]:removeFromParent()
			self.goods[i] = nil
			if level < 10 then
				self.goods[i] = GoodsSprite:create(type_,level + 1):addTo(self.boxs[i])
			end
			addBolt(i)
		end
	end

	if self.heartNum <= 0 then
		self:addMenuPanel(true)
	end
end
return GameSceneA 
