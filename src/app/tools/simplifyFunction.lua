--
-- Author: ccy
-- Date: 2015-08-22 19:31:11
--
function addTouchListener(item,began,moved,ended,canceled)
	item:addTouchEventListener(function(sender,eventType)
		if eventType == ccui.TouchEventType.began and began then
			began(sender,eventType)
		elseif eventType == ccui.TouchEventType.moved and moved then
			moved(sender,eventType)
		elseif eventType == ccui.TouchEventType.ended and ended then
			ended(sender,eventType)
		elseif eventType == ccui.TouchEventType.canceled and canceled then
			canceled(sender,eventType)
		end
	end)
end
function addTouchListenerEnded(item,ended)
	addTouchListener(item,nil,nil,ended,nil)
end

--权重随机 根据权重 返回值
function randomByWeight(...)
	local params = {...}
	local sum = 0
	for k,v in pairs(params) do
		sum = sum + v 
	end
	local weight = math.random(0,sum)
	local i = #params 
	local tmpSum = sum 
	repeat 
		tmpSum = tmpSum - params[i]
		i = i - 1
	until tmpSum <= weight 
	return i + 1
end