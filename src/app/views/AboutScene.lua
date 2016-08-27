
local AboutScene = class("AboutScene", cc.load("mvc").ViewBase)
--local GoodsSprite = import(".GoodsSprite")

AboutScene.RESOURCE_FILENAME = "AboutScene.csb"

function AboutScene:onCreate()

    addTouchListenerEnded(self:getResourceNode():getChildByTag(13),function()
         self:getApp():enterScene("MainScene")
    end)
end


return AboutScene
