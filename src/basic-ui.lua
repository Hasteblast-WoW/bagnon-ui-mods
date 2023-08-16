function CreateSquare(squareName, colour)
    local square = CreateFrame("Frame", squareName, UIParent)
    square:SetFrameStrata("BACKGROUND")
    square:SetWidth(5)
    square:SetHeight(5)
    square.texture = square:CreateTexture(nil,"BACKGROUND")
    square.texture:SetAllPoints(square)
    -- square:SetPoint("TOPLEFT",x,y)
    square:Show()
    square.texture:SetColorTexture(colour[1], colour[2], colour[3])

    return square
end

