local Lib = LibStub:GetLibrary("LibMayronGUI");
if (not Lib) then return; end

local WidgetsPackage = Lib.WidgetsPackage;
local Private = Lib.Private;

local DynamicFrame = WidgetsPackage:CreateClass("DynamicFrame", Private.FrameWrapper);
---------------------------------
---------------------------------

do
    -- need to show scroll bar if height is too much!
    --local children = {}; use EmptyTable and some MoveToTable function for better performance

    local function OnSizeChanged(self, width, height)
        width = math.ceil(width);

        local scrollChild = self:GetScrollChild();
        local anchor = tk.select(1, scrollChild:GetChildren());

        if (not anchor) then 
            return; 
        end

        local totalRowWidth = 0; -- used to make new rows
        local largestHeightInPreviousRow = 0; -- used to position new rows with correct Y Offset away from previous row
        local totalHeight = 0; -- used to dynamically set the ScrollChild's height so that is can be visible
        local previousChild;

        for id, child in Private:IterateArgs(scrollChild:GetChildren()) do
            child:ClearAllPoints();
            totalRowWidth = totalRowWidth + child:GetWidth();

            if (id ~= 1) then
                totalRowWidth = totalRowWidth + self.spacing;
            end

            if ((totalRowWidth) > (width - self.padding * 2) or id == 1) then
                -- NEW ROW!
                if (id == 1) then
                    child:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", self.padding, -self.padding);
                    totalHeight = totalHeight + self.padding;

                else
                    local yOffset = (largestHeightInPreviousRow - anchor:GetHeight());
                    yOffset = ((yOffset > 0 and yOffset) or 0) + self.spacing;
                    child:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -(yOffset));
                    totalHeight = totalHeight + self.spacing;
                    anchor = child;

                end

                totalRowWidth = child:GetWidth();
                totalHeight = totalHeight + largestHeightInPreviousRow;
                largestHeightInPreviousRow = child:GetHeight();
            else
                child:SetPoint("TOPLEFT", previousChild, "TOPRIGHT", self.spacing, 0);

                if (child:GetHeight() > largestHeightInPreviousRow) then
                    largestHeightInPreviousRow = child:GetHeight();
                end
            end

            previousChild = child;
        end

        totalHeight = totalHeight + largestHeightInPreviousRow + self.padding;
        totalHeight = (totalHeight > 0 and totalHeight) or 10;
        totalHeight = math.floor(totalHeight + 0.5);

        -- update ScrollChild Height dynamically:
        scrollChild:SetHeight(totalHeight);

        if (self.parentScrollFrame) then
            local parent = self.parentScrollFrame;            
            OnSizeChanged(parent, parent:GetWidth(), parent:GetHeight());
        end
    end

    -- @constructor
    function Lib:CreateDynamicFrame(parent, spacing, padding)
        local scroller, scrollChild = Lib:CreateScrollFrame(parent, nil, padding);

        scroller:HookScript("OnSizeChanged", OnSizeChanged);
        scroller.spacing = spacing or 4;
        scroller.padding = padding or 4;

        return DynamicFrame({scrollChild = scrollChild}, scroller);
    end

    -- adds children to ScrollChild of the ScrollFrame
    function DynamicFrame:AddChildren(data, ...)
        local width, height = data.frame:GetSize();

        if (width == 0 and height == 0) then
            data.frame:SetSize(UIParent:GetWidth(), UIParent:GetHeight());
        end

        for _, child in Private:IterateArgs(...) do
            child:SetParent(data.scrollChild);
        end

        OnSizeChanged(data.frame, data.frame:GetWidth(), data.frame:GetHeight());
    end
end

function DynamicFrame:GetChildren(data, n, rawget)
    return data.scrollChild:GetChildren();
end

-- TODO
function DynamicFrame:RemoveChild(data, child) end