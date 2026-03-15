local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local PriceInput = Instance.new("TextBox")
local SearchBtn = Instance.new("TextButton")
local CarList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- حماية السكربت بوضعه في CoreGui (إذا كان المشغل يدعم ذلك)
ScreenGui.Name = "CarPriceScanner"
ScreenGui.Parent = (game:GetService("RunService"):IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui")) or CoreGui

-- تصميم النافذة الرئيسية (قابلة للسحب)
MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.Size = UDim2.new(0, 300, 0, 420)
MainFrame.Active = true
MainFrame.Draggable = true 

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

-- العنوان
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Font = Enum.Font.GothamBold
Title.Text = "🚗 رادار الأسعار 🚗"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 22

-- مربع إدخال السعر
PriceInput.Parent = MainFrame
PriceInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
PriceInput.Position = UDim2.new(0.05, 0, 0.14, 0)
PriceInput.Size = UDim2.new(0.9, 0, 0, 40)
PriceInput.Font = Enum.Font.Gotham
PriceInput.PlaceholderText = "أدخل السعر (مثال: 100000)"
PriceInput.Text = ""
PriceInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PriceInput.TextSize = 16
local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 8)
InputCorner.Parent = PriceInput

-- زر البحث
SearchBtn.Parent = MainFrame
SearchBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
SearchBtn.Position = UDim2.new(0.05, 0, 0.26, 0)
SearchBtn.Size = UDim2.new(0.9, 0, 0, 40)
SearchBtn.Font = Enum.Font.GothamBold
SearchBtn.Text = "بحث عن الأسعار"
SearchBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBtn.TextSize = 18
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SearchBtn

-- قائمة السيارات (ScrollingFrame)
CarList.Parent = MainFrame
CarList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
CarList.Position = UDim2.new(0.05, 0, 0.38, 0)
CarList.Size = UDim2.new(0.9, 0, 0.58, 0)
CarList.CanvasSize = UDim2.new(0, 0, 0, 0)
CarList.ScrollBarThickness = 5
local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = CarList

UIListLayout.Parent = CarList
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

---------------------------------------------------------
-- المنطق والبحث داخل الماب
---------------------------------------------------------

local isSearching = false
local targetPrice = 0

-- ⚠️ يجب تعديل هذه المسارات لتطابق مسارات السيارات في الماب الفعلي
local ShowroomFolder = workspace:FindFirstChild("Showroom") 
local MarketFolder = workspace:FindFirstChild("Market") 

-- دالة لاستخراج سعر السيارة (يجب تعديلها حسب أين يخبئ المطور السعر)
local function getCarPrice(car)
    -- هذا مجرد مثال: قد يكون السعر في IntValue أو StringValue داخل موديل السيارة
    local priceValue = car:FindFirstChild("Price") 
    if priceValue then
        return tonumber(priceValue.Value) or 0
    end
    -- أحياناً يكون السعر في خصائص (Attributes)
    local attributePrice = car:GetAttribute("Price")
    if attributePrice then
        return tonumber(attributePrice) or 0
    end
    
    return 0
end

local function refreshList()
    -- مسح السيارات القديمة من القائمة
    for _, child in pairs(CarList:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local yOffset = 0
    local function scanFolder(folder, locationName)
        if not folder then return end
        for _, car in pairs(folder:GetChildren()) do
            local price = getCarPrice(car)
            if price >= targetPrice then
                local CarLabel = Instance.new("TextLabel")
                CarLabel.Parent = CarList
                CarLabel.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
                CarLabel.Size = UDim2.new(0.95, 0, 0, 35)
                CarLabel.Font = Enum.Font.Gotham
                CarLabel.Text = string.format("%s | %s | %s$", locationName, car.Name, tostring(price))
                CarLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
                CarLabel.TextSize = 14

                local LabelCorner = Instance.new("UICorner")
                LabelCorner.CornerRadius = UDim.new(0, 6)
                LabelCorner.Parent = CarLabel
                
                yOffset = yOffset + 43 -- حساب المسافة للتمرير (Scroll)
            end
        end
    end

    scanFolder(ShowroomFolder, "المعرض")
    scanFolder(MarketFolder, "الشريطي")
    
    CarList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- عند الضغط على زر البحث
SearchBtn.MouseButton1Click:Connect(function()
    local inputNum = tonumber(PriceInput.Text)
    if inputNum then
        targetPrice = inputNum
        isSearching = true
        SearchBtn.Text = "جاري التحديث التلقائي..."
        SearchBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        refreshList()
    else
        PriceInput.Text = ""
        PriceInput.PlaceholderText = "رجاءً أدخل رقماً صحيحاً!"
    end
end)

-- حلقة لتحديث الواجهة تلقائياً كل ثانيتين لالتقاط السيارات الجديدة
task.spawn(function()
    while task.wait(2) do
        if isSearching then
            refreshList()
        end
    end
end)
