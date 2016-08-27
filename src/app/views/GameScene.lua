
local GameScene = class("GameScene", cc.load("mvc").ViewBase)
local GoodsSprite = import(".GoodsSprite")

GameScene.RESOURCE_FILENAME = "GameScene.csb"

function GameScene:onCreate()
    --每个层的引用
    print("self:getResourceNode() = ",self:getResourceNode())
    print("GameScene.RESOURCE_FILENAME",GameScene.RESOURCE_FILENAME)
    self.mainPanelBG = self:getResourceNode():getChildByTag(14)
    self.statusPanel = self:getResourceNode():getChildByTag(92)
    self.score_label = self.statusPanel:getChildByTag(140):setString(""..0)
    self.maxScore = cc.UserDefault:getInstance():getIntegerForKey("maxScore_"..self.__cname,0)
    self.max_score_label = self.statusPanel:getChildByTag(49):setString(""..self.maxScore)
    --前一次点击位置，只有当点击两次的时候才会放下物品
    self.prePos = nil 
    self.boxPanel = self.mainPanelBG:getChildByTag(22)
    self.boxs = {}
    self.goods = {}
    self.curScore = 0
    self.boxs[0] = self.boxPanel:getChildByTag(200)
    for i=1,36 do
        print("i = "..i)
        local box = self.boxPanel:getChildByTag(126+i)
        self.boxs[i] = box 
        if i == 1 and not GoodsSprite:getFixedPosition() then
            local rect = box:getBoundingBox()
            GoodsSprite:setFixedPosition(rect.width/2, rect.height/2)
        end
        addTouchListenerEnded(box, function(sender)
            if self.goods[i] ~= nil and  i ~= self.prePos then return end
            if self.prePos ~= i then 
                if self.prePos then
                    self.goods[self.prePos]:removeFromParent()
                    self.goods[self.prePos] = nil 
                end
                self:stopBaseGoodsAction()
                local sprite = GoodsSprite:create(self:getGoodInfoByIndex(0))
                                :addTo(box)
                self.goods[i] = sprite 
               local addLevel,vis = self:checkSynthesis(i)
               self:updateGoodsStatus(GoodsSprite.STATUS_MOVE,i,vis,addLevel)
               self.prePos = i 
               print("11111111")
           else
                local type_,level = self:getGoodInfoByIndex(i)
                local addLevel,vis = self:checkSynthesis(i)
                if addLevel then 
                   self:stepWithSuccess(i,type_,vis,level,addLevel,box)
                else
                    self:stepWithFailed(i,type_,vis,level,addLevel,box)
                end
                self:createCurrentGood()
                self.prePos = nil 
                print("22222222222")
           end
        end)
    end
    self:reset(true)
    self:initTouchListener()
    self:playMusic()
    self:adapterScene()
end

function GameScene:adapterScene()
    local frameSize = display.sizeInPixels
    if frameSize.height/frameSize.width < 1.5 then return end 
    local x,y = self.statusPanel:getPosition()
    local deltaY = 1136  - display.sizeInPixels.height/(display.sizeInPixels.width/640)
    print("yyyyyyyyyyyyyyyyy= ",deltaY)
    -- 176  是iphone 5s 与  4s 的长度差
    if deltaY < 0 or deltaY > 176 then return end
 
    y = y - deltaY 
    self.statusPanel:setPosition(x,y)
end

function GameScene:playMusic()
    local idx = math.random(2,3)
    AudioEngine.playMusic(MUSIC_NAMES[idx], true)
end
function GameScene:addMenuPanel(isEnded)
    local MENU_PANEL_TAG = 1354
    if self:getResourceNode():getChildByTag(MENU_PANEL_TAG) then return end
     local menuPanel = cc.CSLoader:createNode("MenuLayer.csb")
        self:getResourceNode():addChild(menuPanel,100,MENU_PANEL_TAG)
        local addMenuTouchListener = function()
            local home_button = menuPanel:getChildByTag(54)
            addTouchListenerEnded(home_button, function()
                self:getApp():enterScene("MainScene")
                end)
            local restart_button = menuPanel:getChildByTag(55)
            addTouchListenerEnded(restart_button, function()
                self:getApp():enterScene(self.__cname)
                end)
            local continue_button = menuPanel:getChildByTag(56)
            addTouchListenerEnded(continue_button, function()
                menuPanel:removeFromParent()
                end)
            if isEnded then 
                AudioEngine.playEffect(MUSIC_NAMES[4])
                AudioEngine.stopMusic()
                continue_button:setVisible(false) 
            end
        end
    addMenuTouchListener()
end

function GameScene:initTouchListener()
    local pause_button = self.statusPanel:getChildByTag(88)
    addTouchListenerEnded(pause_button, function()
        self:addMenuPanel()
    end)
end
function GameScene:reset(isFirst)
    for i = 0,36 do
        if nil ~= self.goods[i] then
            self.goods[i]:removeFromParent()
            self.goods[i] = nil 
        end
    end
    self:createCurrentGood()
    for i=1,5 do
        local x = math.random(1,6)
        local y = math.random(1,6)
        print(x,y)
        local pos = (y-1)*6+x
        local nType ,nLevel = self:createGoodInfo()
        if self.goods[pos] == nil and self:checkSynthesis(pos,nType,nLevel) == false then
            self.goods[pos] = GoodsSprite:create(nType,nLevel,nil,x,y):addTo(self.boxs[pos])
        end
    end
end

function GameScene:createCurrentGood(type_,level)
    if self.goods[0] ~= nil then
        self.goods[0]:removeFromParent()
        self.goods[0] = nil 
    end
    local tmpType_,tmpLevel = self:createGoodInfo()
    type_ = type_ or tmpType_ 
    level = level or tmpLevel 
    print("type = "..type_)
    self.goods[0] = GoodsSprite:create(type_,level):addTo(self.boxs[0])
end
--synthesis 合成
function GameScene:checkSynthesis(pos,targetType,targetLevel)
    if not targetType or not targetLevel then 
        targetType,targetLevel = self:getGoodInfoByIndex(pos)
    end
    local vis = {}
    local queue = {}
    local forward = {-6,1,6,-1}
    local rear,front = 0,0
    queue[0] = pos 
    vis[pos] = true 
    local returnVis = {}
    returnVis[pos]= true 
    local tmpSum = 1
    local addLevel = 0
    while rear >= front do
        local curPos = queue[front]
        print("curPos = ",curPos)
        front = front + 1
        for i=1,4 do
            local tmpPos = curPos + forward[i]
            local flag = true
            if i == 4 and tmpPos%6 == 0 then flag=false end
            if i == 2 and tmpPos%6 == 1 then flag = false end
            if tmpPos >=1 and tmpPos <= 36 and flag and not vis[tmpPos] and self.goods[tmpPos] then
                local tmpType,tmpLevel = self:getGoodInfoByIndex(tmpPos)
                if tmpType == targetType and tmpLevel == targetLevel then
                    vis[tmpPos] = true 
                    rear = rear + 1
                    queue[rear] = tmpPos
                    tmpSum = tmpSum + 1
                end
            end
        end
        --如果可以合成，查看合成后是否可以再次合成
        if rear < front and tmpSum >= 3 then
            tmpSum = 1
            rear = rear + 1
            queue[rear] = pos 
            targetLevel = targetLevel + 1
            addLevel = addLevel + 1
            for i=1,36 do
                if vis[i] == true then 
                    returnVis[i] = true 
                    vis[i] = false 
                end
            end
            vis[pos] = true 
        end
    end
    if addLevel >= 1 then
        return addLevel,returnVis 
    else
        return false,returnVis
    end
end

function GameScene:updateGoodsStatus(status,pos,vis,flag)
    local posChangeToXY = function(pos)
        local x = (pos-1)%6 + 1 
        local y = (pos-1)/6 + 1
        return x,math.floor(y)
    end
    local comparePos = function(curPos,targetPos)
        if targetPos < curPos then return 1
        elseif targetPos == curPos then return 0
        else return -1 end
    end
    local curX,curY = posChangeToXY(pos)
    for i=1,36 do
        if vis[i] == true and flag or i == pos then
            local tmpX,tmpY = posChangeToXY(i)
            print("compareX,y pos "..i,comparePos(curX,tmpX),40*comparePos(curY,tmpY))
            self.goods[i]:setStatus(status,40*comparePos(curX,tmpX),40*comparePos(curY,tmpY))
        end
    end
end


function GameScene:getGoodInfoByIndex(index)
    print("index ="..index)
    if not self.goods[index] then return nil,nil end
    index = index or 0
    return self.goods[index]:getType(),self.goods[index]:getLevel()
end

function GameScene:clearBaseGoods(vis)
    for i=1,36 do
        if vis[i] then 
            self.goods[i]:removeFromParent()
            self.goods[i] = nil 
        end
    end
end

function GameScene:calcAddScore(vis)
    local maxLevel = 1
    for i=1,36 do
        if vis[i] then 
            local type_,level =  self:getGoodInfoByIndex(i)
            if level > maxLevel then maxLevel = level end
        end
    end
    local baseScore = maxLevel * 10
    local boxNum = 0
    local score = 0
    local addFloatScoreLabel = function(k,score)
        local label = self.mainPanelBG:getChildByTag(106):clone()
        label:setPosition(44,22)
        label:setString(""..score)
        label:setVisible(true):addTo(self.boxs[k],100)
        local action1 = cc.MoveBy:create(0.7,cc.p(0,100))
        local action2 = cc.CallFunc:create(function()
            label:removeFromParent()
            end)
       label:runAction(cc.Sequence:create(action1,action2))

    end
    for i=1,36 do 
        if vis[i] then
            boxNum = boxNum + 1
            local num = boxNum * baseScore
            score = score + num 
            addFloatScoreLabel(i,num)
        end
    end

    return score

end

function GameScene:stopBaseGoodsAction()
    for i=1,36 do 
        if self.goods[i] then self.goods[i]:reset() end
    end
end

--检查游戏是否结果
function GameScene:checkIsGameEnded()
    for i=1,36 do 
        if self.goods[i] == nil then
            return false
        end
    end
    return true
end
--创建一个物品，返回物品信息
--不同关卡的游戏规则主要这个地方做出区分
function GameScene:createGoodInfo()
    local level = randomByWeight(40,20,10)
    local type_ = GoodsSprite.TYPE_PLANT
    return  type_ ,level 
end
--走完一步，成功合成
function GameScene:stepWithSuccess(i,type_,vis,level,addLevel,box)
    local addScore = self:calcAddScore(vis)
    self.curScore = self.curScore + addScore
    self.score_label:setString(""..self.curScore)
    if self.curScore > self.maxScore then 
        self.maxScore = self.curScore 
        cc.UserDefault:getInstance():setIntegerForKey("maxScore_"..self.__cname,self.maxScore)
        self.max_score_label:setString(""..self.maxScore)
    end
    self:clearBaseGoods(vis)
    if level + addLevel > 10 then
        self.goods[i] = nil 
        return 
    else
        local sprite = GoodsSprite:create(type_,level+addLevel):addTo(box)
        self.goods[i] = sprite
    end
end
--走完一步，没有合成
function GameScene:stepWithFailed(i,type_,vis,level,addLevel,box)
    self.goods[i]:reset()
    if self:checkIsGameEnded() then
        self:addMenuPanel(true)
    end
end


 return GameScene
