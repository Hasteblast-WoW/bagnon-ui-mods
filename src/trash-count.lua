local Addon, Private =  ...

-- TODO: Figure out how this gets injected for Bagnon
_G["BagnonUIMods"] = Private

Private.JunkItems = {}
Private.JunkTotal = 0

print("[bagnon-ui-mods] Loading Trash Count UI Mod...")

local vendorTrashCount = CreateFrame("Frame", "vendorTrashCount", nil, "SmallMoneyFrameTemplate")
local t = vendorTrashCount:CreateFontString(nil, "OVERLAY", "GameTooltipText")
t:SetPoint("LEFT", vendorTrashCount, -40, 0)
t:SetText("JUNK: ")

local function OnToggle()
    local bgnInventoryFrame = _G["BagnonInventory1"]
    if bgnInventoryFrame and bgnInventoryFrame:IsVisible() then
        vendorTrashCount:SetPoint("BOTTOM", bgnInventoryFrame.BottomRightCorner, -20, -20)
        vendorTrashCount:Show()
    else
        vendorTrashCount:Hide()
    end
end


local function OnItemUpdate(items)
    -- FIXME: Bug - on first character swap, junk total doesn't update
    if items == nil or items.bags == nil or items.order == nil then
        return
    end

    Private.JunkTotal = 0

    local bgnInventoryFrame = _G["BagnonInventory1"]
    local owner = (bgnInventoryFrame.owner and bgnInventoryFrame.owner.address) or Bagnon.player.address
    for _, item in ipairs(items.order) do
        -- NUM_BAG_SLOTS is total number of inventory bag slots
        -- BACKPACK_CONTAINER is the first inventory bag
        if item.bag >= BACKPACK_CONTAINER and item.bag <= NUM_BAG_SLOTS then
            -- Inventory Item
            -- TODO: Check why this is zero'ing out even when there is one item
            if item.count == 0 then
                item.count = 1
            end

            if item.info.quality == 0 and owner == item:GetOwner().address then
                -- Junk item owned by current "owner"
                if not Private.JunkItems[owner] then
                    Private.JunkItems[owner] = {}
                end

                if not Private.JunkItems[owner][item.info.itemID] ~= nil then
                    Private.JunkItems[owner][item.info.itemID] = item
                end

                local sellPrice, _ = select(11, GetItemInfo(item.info.itemID))
                Private.JunkTotal = Private.JunkTotal + (sellPrice * item.count)
            end
        end
    end

    -- TODO: Determine why this is needed - conflicts with other money counter otherwise
    MoneyFrame_SetType(vendorTrashCount, "STATIC")
    MoneyFrame_Update(vendorTrashCount, Private.JunkTotal, Private.JunkTotal == 0)
    vendorTrashCount:Show()
end

hooksecurefunc(Bagnon.Frame, 'OnShow', OnToggle)
hooksecurefunc(Bagnon.Frame, 'OnHide', OnToggle)
hooksecurefunc(Bagnon.ItemGroup, "Layout", OnItemUpdate)
