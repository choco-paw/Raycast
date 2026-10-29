This is a system which allows you to highlight any object within the workspace.

List of functions:

```
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))() -- Loading the library

ESPLibrary:AddESP({
Object = Instance, -- The object you want to highlight
Text = string, -- What you want the text to say,
Color = Color3 -- The color of the esp to set.
})

ESPLibrary:RemoveESP(Instance) -- Removes esp from the object

ESPLibrary:SetTextSize(number) -- Sets the text size

ESPLibrary:SetFillTransparency(number) -- Sets the highlight's fill transparency

ESPLibrary:SetOutlineTransparency(number) -- Sets the outline transparency

ESPLibrary:SetTextTransparency(number) -- Sets the text transparency

ESPLibrary:SetTextOutlineTransparency(number) -- Sets the outline transparency for text

ESPLibrary:SetFadeTime(number) -- Sets the esp fade time

ESPLibrary:SetFont(Font) -- Sets the font of all text

ESPLibrary:SetRainbow(Boolean) -- Changes if the esp should be rainbow

ESPLibrary:SetShowDistance(Boolean) -- Sets whether the esp should show how far away it is

ESPlibrary:SetMatchColors(Boolean) -- Sets whether the fill color and outline color should be the same

ESPLibrary:SetOutlineColor(Color3) -- Sets the outline color for if MatchColors is false

ESPLibrary:UpdateObjectText(Instance, Text) -- Changes the text of an object if it is already highlighted

ESPLibrary:UpdateObjectColor(Instance, Color3) -- Changes the color of an object if it is already highlighted

ESPLibrary:SetTracers(Boolean) -- Sets whether tracers are currently visible

ESPLibrary:SetTracerOrigin(string) -- Sets where the tracers come from on the screen (Can only be either "Bottom, "Top", "Center" or "Mouse")

ESPLibrary:SetTracerSize(number) -- Sets the multiplier of how big the tracers are (default is '1')

ESPLibrary:SetDistanceSizeRatio(number) -- Sets how big the distance text should be compared to the main text (default is '1')

ESPLibrary:SetArrows(Boolean) - Sets whether arrows will appear, showing highlighted objects that are off screen.

ESPLibrary:SetArrowRadius(Number) - Sets how far the arrows will be from the center of the screen. (default is 200)

ESPLibrary:Unload() -- Unloads the library, removing all highlights and preventing any more objects being highlighted
```

Example Usage:

```
local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/bocaj111004/ESPLibrary/refs/heads/main/Library.lua"))()
local Character = game.Players.LocalPlayer.Character

ESPLibrary:SetTextSize(22)
ESPLibrary:SetFadeTime(0.5)

ESPLibrary:AddESP({
Object = Character,
Text = Character.Name,
Color = Color3.fromRGB(0,255,0)
})

task.wait(5)

ESPLibrary:UpdateObjectColor(Character, Color3.fromRGB(255,0,0))
ESPLibrary:UpdateObjectText(Character, Character.Name .. " [Removing Soon]") -- Changes the text of the highlight

task.wait(5)

ESPLibrary:RemoveESP(Character) -- Removes esp from the player's character.
```

You can also edit the settings of the esp with your executor:

```
local ESPLibrary = getgenv().ESPLibrary

ESPLibrary:SetRainbow(true)
```
