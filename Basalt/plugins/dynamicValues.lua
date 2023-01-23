return {
    VisualObject = function(base)
        local dynObjects = {}
        local curProperties = {}

        local function stringToNumber(str)
            local ok, result = pcall(load("return " .. str, "", nil, {math=math}))
            if not(ok)then error(str.." is not a valid dynamic value string") end
            return result
        end

        local function createDynamicValue(self, key, val)
            local properties = {x="getX", y="getY", w="getWidth", h="getHeight"}
            local objectGroup = {}
            for a,b in pairs(properties)do
                for v in val:gmatch("%a+%."..a) do
                    local name = v:gsub("%."..a, "")
                    if(name~="self")and(name~="parent")then 
                        table.insert(objectGroup, name) 
                    end
                end
            end

            local parent = self:getParent()
            local objects = {}
            for k,v in pairs(objectGroup)do
                objects[v] = parent:getObject(v)
                if(objects[v]==nil)then
                    error("Dynamic Values - unable to find object: "..v)
                end
            end
            objects["self"] = self
            objects["parent"] = parent

            dynObjects[key] = function()
                local mainVal = val
                for a,b in pairs(properties)do
                    for v in val:gmatch("%w+%."..a) do
                        local obj = objects[v:gsub("%."..a, "")]
                        if(obj~=nil)then
                            mainVal = mainVal:gsub(v, obj[b](obj))
                        else
                            error("Dynamic Values - unable to find object: "..v)
                        end
                    end
                end
                curProperties[key] = math.floor(stringToNumber(mainVal)+0.5)
            end
            dynObjects[key]()
        end

        local function updatePositions(self)
            if(#dynObjects>0)then
                for k,v in pairs(dynObjects)do
                    v()
                end
                local properties = {x="getX", y="getY", w="getWidth", h="getHeight"}
                for k,v in pairs(properties)do
                    if(dynObjects[k]~=nil)then
                        if(curProperties[k]~=self[v](self))then
                            if(k=="x")or(k=="y")then
                                base.setPosition(self, curProperties["x"] or self:getX(), curProperties["y"] or self:getY())
                            end
                            if(k=="w")or(k=="h")then
                                base.setSize(self, curProperties["w"] or self:getWidth(), curProperties["h"] or self:getHeight())
                            end
                        end
                    end
                end
            end
        end

        local object = {
            updatePositions = updatePositions,
            createDynamicValue = createDynamicValue,

            setPosition = function(self, xPos, yPos, rel)
                curProperties.x = xPos
                curProperties.y = yPos
                if(type(xPos)=="string")then
                    createDynamicValue(self, "x", xPos)
                end
                if(type(yPos)=="string")then
                    createDynamicValue(self, "y", yPos)
                end
                base.setPosition(self, curProperties.x, curProperties.y, rel)
                return self
            end,

            setSize = function(self, w, h, rel)
                curProperties.w = w
                curProperties.h = h
                if(type(w)=="string")then
                    createDynamicValue(self, "w", w)
                end
                if(type(h)=="string")then
                    createDynamicValue(self, "h", h)
                end
                base.setSize(self, curProperties.w, curProperties.h, rel)
                return self
            end,

            customEventHandler = function(self, event, ...)
                base.customEventHandler(self, event, ...)
                if(event=="basalt_FrameReposition")or(event=="basalt_FrameResize")then
                    updatePositions(self)
                end
            end,
        }

        return object
    end
}