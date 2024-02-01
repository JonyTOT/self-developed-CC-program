local basalt = require("basalt")
local cnt = peripheral.wrap("toms_storage:ts.inventory_connector.tile_0")
local win = basalt.addMonitor():setMonitor("monitor_0")
local c1,c2,maxpage = {},{},nil
local Panel = win:addFrame()
local ScrollTimer = win:addTimer()
local InventoryThread = win:addThread()
local Inventory,InventoryLen = nil,nil

function Init()
    win:setBackground(colours.black)
        :setForeground(colours.white)
    local TLabel = win:addLabel()
        :setPosition(1,1):setSize("{parent.w}",1)
        :setText("Inventory "):setTextAlign("center")
    Panel:setBackground(colours.black):setForeground(colours.white)
        :setPosition(2,2):setSize("{parent.w-3}","{parent.h-3}"):setBorder(colours.white)    
    for i=1,4 do
        c1[i] = Panel:addLabel():setPosition(2,i*2):setSize("{(parent.w/2)-3}",1)
            :setText("none")
        c2[i] = Panel:addLabel():setPosition("{(parent.w/2)}",i*2):setSize("{(parent.w/2)-1}",1)
            :setText("NaN"):setTextAlign("right")
    end
end

function InventoryList()
    local size = cnt.size()
    local SD = nil
    local ItemList = {}
    for slot=1,size do
        SD = cnt.getItemDetail(slot)
        if SD ~= nil then ItemList[#ItemList+1] = {#ItemList+1,string.sub(SD["name"],string.find(SD["name"],":",1)+1,#SD["name"]),SD["count"]} end
    end  
    local ItemList_len = #ItemList
    if ItemList_len % 4 ~= 0 and ItemList_len ~= 0 then
        for len=1,((math.floor(ItemList_len/4)+1)*4)-ItemList_len do
            ItemList[len+ItemList_len] = {len+ItemList_len," "," "}
        end
    end
    rednet.broadcast(ItemList,"JT-INVENTORY")
    return ItemList,#ItemList
end

function ScrollPage(maxpage,page)
    if maxpage == 0 then
        for line=1,4 do
            c1[line]:setText(" ")
            c2[line]:setText(" ")
        end
    else      
        for line=1,4 do
            c1[line]:setText(Inventory[line+((page-1)*4)][2])
            c2[line]:setText(Inventory[line+((page-1)*4)][3])
        end
    end
end

function main()
    page = 1
    Init()
    InventoryThread:start(
        function()
            while true do
                Inventory,InventoryLen = InventoryList()
                
                sleep(0.5)
            end
        end
    )

    ScrollTimer:setTimer(3):start()
    ScrollTimer:onCall(
        function()
            maxpage = math.floor(InventoryLen / 4)
            ScrollPage(maxpage,page)  
            page = page + 1      
            if page > maxpage then page = 1 end
            ScrollTimer:start()
        end)
    basalt.autoUpdate(true)
    shell.run("monitor monitor_0 clear")
end
main()
