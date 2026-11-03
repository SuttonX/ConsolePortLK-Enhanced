"""Run compatibility regressions against production Lua chunks using Lua 5.1."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

def read(p): return Path(p).read_text()
def run(code): LuaRuntime().execute(code)

s=read('ConsolePort/Drivers/Button.lua')
chunk=s[s.index('function Button:OnMouseDown()'):s.index('-- HotKey textures')]
run('''local Button={}; local KEY={STATE_DOWN=1,STATE_UP=0}
'''+chunk+'''
local a,b={},{ };function a:SetButtonState(s)self.state=s end
function b:SetButtonState(s)self.state=s end
local input=setmetatable({target=a},{__index=Button})
function input:GetAttribute(k)if k=='type' then return 'click' else return self.target end end
input:OnMouseDown();assert(a.state=='PUSHED');input.target=b
input:OnMouseUp();assert(a.state=='NORMAL' and b.state==nil)
input:OnMouseDown();input:Clear();assert(b.state=='NORMAL' and input.pushedButton==nil)
print('PASS: focus changes and cancellation release the actual pressed button')
''')
s=read('ConsolePort/Frames/Item.lua')
chunk=s[s.index('local INVALID_QUICKBIND_INV_TYPES'):s.index('function ItemMenu:IsEquippableItem()')]
run('''local ItemMenu={};local item
local function GetItemLink()return item end
GetItemInfo=function()return nil,nil,nil,nil,nil,nil,nil,nil,'INVTYPE_TRINKET' end
GetItemSpell=function()return 'Use effect' end
function ItemMenu:GetStackCount()return nil end
function ItemMenu:GetCount()return nil end
'''+chunk+'''
item='trinket';assert(not ItemMenu:IsQuickBindItem())
GetItemInfo=function()return nil,nil,nil,nil,nil,nil,nil,nil,'INVTYPE_WEAPON' end
assert(ItemMenu:IsQuickBindItem());assert(not ItemMenu:IsSplittableItem())
function ItemMenu:GetStackCount()return 20 end
function ItemMenu:GetCount()return 5 end
assert(ItemMenu:IsSplittableItem())
print('PASS: inventory tokens and missing item cache data')
''')
s=read('ConsolePortBar/Libs/ActionButton.lua')
chunk=s[s.index('local function FindSpellBookSlot(spellID)'):s.index('--- Item Button')]
run('''local Spell={};GetNumSpellTabs=function()return 2 end
GetSpellTabInfo=function(i)if i==1 then return '',nil,0,1 else return '',nil,1,2 end end
GetSpellLink=function(slot)return slot==3 and '|Hspell:123:0|h[Test]|h' or '|Hspell:999:0|h[Other]|h' end
IsAttackSpell=function(slot)assert(slot==3);return true end
IsAutoRepeatSpell=IsAttackSpell
IsSpellInRange=function(slot,book,unit)assert(slot==3 and unit=='target');return 1 end
'''+chunk+'''
local b={_state_action=123};assert(Spell.IsAttack(b));assert(Spell.IsAutoRepeat(b));assert(Spell.IsUnitInRange(b,'target')==1)
assert(Spell.GetCount(b)==0);b._state_action=456;assert(Spell.IsAttack(b)==nil)
print('PASS: stock Wrath spellbook lookup without modern helper or spell-count API')
''')
# The production empty-slot branch must clear both layers independently.
chunk=s[s.index('\t\tActiveButtons[self] = nil',s.index('function Update(self)')):s.index('\n\t-- Add a green border')]
chunk=chunk.rsplit('\n\tend',1)[0]
run('''local self={cooldown={Hide=function()end},FakeChecked={},tripleShims={{FakeChecked={}}}}
function self.FakeChecked:SetAlpha(a)self.alpha=a end
function self.tripleShims[1].FakeChecked:SetAlpha(a)self.alpha=a end
function self:SetChecked(a)self.checked=a end
function self:FadeOut()end
local ActiveButtons,ActionButtons,NonActionButtons={},{},{}
local function UpdateUsable()end;local function UpdatePage()end
'''.replace('function self.tripleShims[1].FakeChecked:SetAlpha(a)self.alpha=a end','self.tripleShims[1].FakeChecked.SetAlpha=self.FakeChecked.SetAlpha')+chunk+'''
assert(self.FakeChecked.alpha==0 and self.tripleShims[1].FakeChecked.alpha==0)
print('PASS: empty slots clear main and modifier checked overlays')
''')
s=read('ConsolePortBar/Core/Wrapper.lua')
chunk=s[s.index('function WrapperMixin:SetClassicBorders(enabled)'):s.index('function WrapperMixin:SetBorderColor')]
run('''local WrapperMixin={};local ab={cfg={useSquareButtons=true},libs={}}
local modcoords={};local buttonTextures={['']={border='round'}}
local function region()
 local r={}
 for _,k in ipairs({'ClearAllPoints','SetPoint','SetSize','Hide','Show','SetAlpha','SetFrameLevel','SetFrameStrata','SetTexCoord'})do r[k]=function()end end
 function r:SetAllPoints(target)self.anchor=target end
 function r:SetTexture(t)self.texture=t end
 return r
end
local b={}
for _,k in ipairs({'NormalTexture','PushedTexture','HighlightTexture','CheckedTexture','Border','icon','cooldown'})do b[k]=region()end
function b:GetNormalTexture()return self.NormalTexture end
function b:GetPushedTexture()return self.PushedTexture end
function b:GetHighlightTexture()return self.HighlightTexture end
function b:GetCheckedTexture()return self.CheckedTexture end
function b:GetWidth()return 45 end
function b:GetFrameLevel()return 2 end
function b:GetFrameStrata()return 'MEDIUM' end
function b:UpdateAction()end
local w=setmetatable({Buttons={['']=b},['']=b},{__index=WrapperMixin})
'''+chunk+'''
w:SetClassicBorders(true);assert(b.Border.texture:find('SquareNormal') and b.Border.anchor==b.NormalTexture)
ab.cfg.useSquareButtons=false;w:SetClassicBorders(true)
assert(b.Border.texture=='round' and b.Border.anchor==b)
print('PASS: equipped overlay switches square/round with the layout')
''')
s=read('ConsolePortBar/Custom/Blizzard.lua')
chunk=s[s.index('local function GetClassBarOffset()'):s.index('\n\tlocal stanceBar')]
run('local ab={cfg={}};'+chunk+'''
ab.cfg={activePreset='Crossbar: Minimal',layout={CP_T1={}}};assert(GetClassBarOffset()==-5)
ab.cfg.layout.CP_T3={};assert(GetClassBarOffset()==24)
ab.cfg.layout.CP_T3.hidden=true;assert(GetClassBarOffset()==-5)
ab.cfg.activePreset='Orthodox';assert(GetClassBarOffset()==-76)
ab.cfg.activePreset='Default';assert(GetClassBarOffset()==24)
print('PASS: layout-specific stance/totem offsets and optional-button rules')
''')
s=read('ConsolePortBar/Core/Bar.lua')
start=s.index("    if cfg.activePreset == 'Crossbar: Minimal' and (cfg.minimalCenterGapVersion or 0) < 3 then")
chunk=s[start:s.index('    local hideIcons',start)]
run('''for version=0,3 do
 local spread=version==0 and 0 or (version==1 and 10.45 or (version==2 and 10.20 or 9.95))
 local cfg={activePreset='Crossbar: Minimal',minimalCenterGapVersion=version}
 local layout={left={point={'BOTTOM',-30-spread,50}},right={point={'BOTTOM',30+spread,50}},other={point={'CENTER',17,19}}}
'''+chunk+'''
 assert(math.abs(layout.right.point[2]-39.95)<0.000001)
 assert(math.abs(layout.left.point[2]+39.95)<0.000001)
 assert(layout.other.point[2]==17 and cfg.minimalCenterGapVersion==3)
'''+chunk+'''
 assert(math.abs(layout.right.point[2]-39.95)<0.000001)
end
print('PASS: Minimal migrations from every previous version are idempotent')
''')
s=read('ConsolePort/Init/Wrapper.lua')
chunk=s[s.index('function CPAPI:GetItemLevelColor'):s.index('function CPAPI:GetAverageItemLevel')]
run('''local CPAPI={};RAID_CLASS_COLORS={DRUID={r=1,g=.5,b=0}}
UnitClass=function()return 'Druid','DRUID' end
'''+chunk+'''
local r,g,b=CPAPI:GetItemLevelColor();assert(r==1 and g==.5 and b==0)
print('PASS: level-cap menu receives numeric RGB values on stock Wrath')
''')
s=read('ConsolePortUI_Menu/Menu_LootButton.lua')
run('''local L={};local timerFired=false
local db={KEY={CIRCLE='circle',TRIANGLE='triangle'},CPAPI={TimerAfter=function(_,f)timerFired=true;f()end},UIFrameFadeIn=function()end}
local hints={};local control={ResetHintBar=function()end,AddHint=function(_,k)hints[#hints+1]=k end}
ConsolePortUI={GetEssentials=function()return {},control,db end}
ITEM_QUALITY_COLORS={[1]={r=1,g=1,b=1},[2]={r=0,g=1,b=0}}
'''+"assert(loadstring([====["+s+"]====]))('ConsolePortUI_Menu',L)"+'''
local b=setmetatable({},{__index=L.LootButton})
function b:GetID()return 1 end;function b:GetAlpha()return 1 end
b:Animate();assert(timerFired)
local color={SetVertexColor=function(self,r,g,b)self.green=g end}
b.Label=color;b.HighlightTexture=color;b.Mask=color
b:UpdateItemQuality(2);assert(color.green==1)
b:UpdateItemQuality(nil);assert(color.green==1)
print('PASS: loot animation and quality tint work without retail globals/methods')
''')

s=read('ConsolePortBar/Core/Bar.lua')
start=s.index("    if cfg.activePreset == 'Crossbar: Triple' and not cfg.tripleShoulderPositionsVersion then")
chunk=s[start:s.index('    -- Apply the half-unit',start)]
run("local cfg={activePreset='Crossbar: Triple'};local layout={CP_T1={point={'BOTTOM',-75,215},size=45},CP_T2={point={'BOTTOM',75,215},scale=.8}};"+chunk+"""
assert(layout.CP_T1.point[2]==-200 and layout.CP_T2.point[2]==200)
assert(layout.CP_T1.point[3]==205 and layout.CP_T2.point[3]==205)
assert(layout.CP_T1.size==45 and layout.CP_T2.scale==.8)
assert(layout.CP_T3==nil and layout.CP_T4==nil)
layout.CP_T1.point[2]=-220
"""+chunk+"""
assert(layout.CP_T1.point[2]==-220)
cfg={activePreset='Crossbar: Minimal'}
"""+chunk+"""
assert(layout.CP_T1.point[2]==-220 and cfg.tripleShoulderPositionsVersion==nil)
cfg={activePreset='Crossbar: Triple'}
layout={CP_T3={point={'BOTTOM',-25,215}},CP_T4={point={'BOTTOM',25,215}}}
"""+chunk+"""
assert(layout.CP_T3.point[2]==-250 and layout.CP_T4.point[2]==250)
assert(layout.CP_T3.point[3]==205 and layout.CP_T4.point[3]==205)

print('PASS: Triple saved shoulders migrate once; hidden buttons and other layouts stay unchanged')
""")
# Custom coordinates after the Minimal migration must survive subsequent loads.
s=read('ConsolePortBar/Core/Bar.lua')
start=s.index("    if cfg.activePreset == 'Crossbar: Minimal' and (cfg.minimalCenterGapVersion or 0) < 3 then")
chunk=s[start:s.index('    local hideIcons',start)]
run("local cfg={activePreset='Crossbar: Minimal'};local layout={CP_T1={point={'BOTTOM',-30,50}}};"+chunk+"layout.CP_T1.point={'TOP',-123,87};"+chunk+"assert(layout.CP_T1.point[1]=='TOP' and layout.CP_T1.point[2]==-123 and layout.CP_T1.point[3]==87);print('PASS: custom Minimal anchor/X/Y survive loads after migration')")
# Exercise the production preset cache/restore path, including migration markers.
s=read('ConsolePortBar/Core/Config.lua')
start=s.index('\tConsolePortBarSetup.presetProfiles = ConsolePortBarSetup.presetProfiles or {}')
chunk=s[start:s.index('\n\n\n\tself.Layout:Hide()',start)]
run('''local function copy(t)
 if type(t)~='table' then return t end
 local r={};for k,v in pairs(t)do r[k]=copy(v)end;return r
end
local db={table={copy=copy}}
local ab={cfg={activePreset='Crossbar: Triple',tripleShoulderPositionsVersion=1,layout={CP_T1={point={'BOTTOM',-222,210}}}}}
function ab:GetBooleanSettings()return {} end
ConsolePortBarSetup=ab.cfg
local Bar={OnLoad=function(_,cfg)ab.cfg=cfg;ConsolePortBarSetup=cfg end}
local function switch(self)
'''+chunk+'''
end
switch({presetName='Crossbar: Minimal',cfg={minimalCenterGapVersion=3,layout={}}})
ab.cfg.layout.CP_T2={point={'BOTTOM',77,89}}
switch({presetName='Crossbar: Triple',cfg={layout={}}})
assert(ab.cfg.layout.CP_T1.point[2]==-222 and ab.cfg.tripleShoulderPositionsVersion==1)
switch({presetName='Crossbar: Minimal',cfg={layout={}}})
assert(ab.cfg.layout.CP_T2.point[2]==77 and ab.cfg.minimalCenterGapVersion==3)
print('PASS: preset switches retain custom coordinates and one-time migration markers')
''')
