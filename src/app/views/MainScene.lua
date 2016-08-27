
local MainScene = class("MainScene", cc.load("mvc").ViewBase)
--local GoodsSprite = import(".GoodsSprite")

MainScene.RESOURCE_FILENAME = "MainScene.csb"
MainScene.isFirst = true

function MainScene:onCreate()
    -- -- add background image
    -- display.newSprite("MainSceneBg.jpg")
    --     :move(display.center)
    --     :addTo(self)

    -- -- add play button
    -- local playButton = cc.MenuItemImage:create("PlayButton.png", "PlayButton.png")
    --     :onClicked(function()
    --         self:getApp():enterScene("PlayScene")
    --     end)
    -- cc.Menu:create(playButton)
    --     :move(display.cx, display.cy - 200)
    --     :addTo(self)
    addTouchListenerEnded(self:getResourceNode():getChildByTag(5):getChildByTag(9),function()
         self:getApp():enterScene("GameScene")
    end)
    addTouchListenerEnded(self:getResourceNode():getChildByTag(5):getChildByTag(13),function()
         self:getApp():enterScene("GameSceneA")
    end)
    addTouchListenerEnded(self:getResourceNode():getChildByTag(5):getChildByTag(10),function()
         self:getApp():enterScene("AboutScene")
    end)
    addTouchListenerEnded(self:getResourceNode():getChildByTag(5):getChildByTag(11),function()
         cc.Director:getInstance():endToLua()
    end)
   self:playBlink()
   math.randomseed(os.time())
end

function MainScene:playBlink()
    if not self.isFirst then AudioEngine.playMusic(MUSIC_NAMES[1], true) return end
    MainScene.isFirst = false
    self:getResourceNode():getChildByTag(5):setVisible(false)
    local blink = display.newSprite("startblink.png"):setAnchorPoint(cc.p(0,0))
    local action1 = cc.EaseOut:create(cc.FadeIn:create(1.5),1)
    local action2 = cc.EaseIn:create(cc.FadeOut:create(1.5),1)
    local action_delay = cc.DelayTime:create(1)
    local action3 = cc.CallFunc:create(function()
        self:getResourceNode():getChildByTag(5):setVisible(true)
        AudioEngine.playMusic(MUSIC_NAMES[1], true)
        end)
    blink:runAction(cc.Sequence:create(action_delay,action2,action3))
    self:getResourceNode():addChild(blink)
end

return MainScene
