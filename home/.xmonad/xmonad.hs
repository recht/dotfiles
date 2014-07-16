-- XMonad Core
import XMonad
import XMonad.Layout
import XMonad.Operations
import qualified XMonad.StackSet as W
 
-- GHC hierarchical libraries
import Data.Bits ((.|.))
import Data.Ratio ((%))
import qualified Data.Map as M
import Graphics.X11
import Graphics.X11.Xlib
import Graphics.X11.Xlib.Extras
import System.IO
 
-- Contribs
import XMonad.Actions.CycleWS
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.Submap
import XMonad.Actions.WindowBringer
import XMonad.Actions.FloatKeys
import XMonad.Actions.NoBorders

import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ICCCMFocus

import XMonad.Layout.NoBorders
import XMonad.Layout.Tabbed
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.Dishes
import XMonad.Layout.IM

import XMonad.Util.EZConfig
import XMonad.Util.Run
import XMonad.Util.Paste

import XMonad.Prompt.Shell
import XMonad.Prompt.Window
import XMonad.Prompt

import XMonad.Hooks.DynamicLog   ( PP(..), dynamicLogWithPP, dzenColor, wrap, defaultPP )

myfont = "\"-xos4-terminus-medium-r-normal--12-120-72-72-c-60-iso8859-1\""
fgcolor = "black"
bgcolor = "white"

statusBarCmd= "dzen2 -e '' -w 660 -h 15 -ta l -xs 1 -fg " ++ fgcolor ++ " -bg " ++ bgcolor ++ " -fn " ++ myfont

-- Get ready!
main = do din <- spawnPipe statusBarCmd
          xmonad $ ewmh defaultConfig
                { XMonad.workspaces     = workspaces'
                , modMask        = modMask'
--                , numlockMask    = 0
                , layoutHook     = layoutHook'
                , terminal       = "urxvtc || urxvt"
		, normalBorderColor = "#dddddd"
		, focusedBorderColor = "#3499dd"
                , manageHook = manageDocks <+> myManageHook
--		, logHook = dynamicLogWithPP $ myPP din
		, logHook = do
			takeTopFocus
			setWMName "LG3D"
			dynamicLogWithPP $ myPP din
                , keys = keys'
                , startupHook = setWMName "LG3D"
                }

modMask'    = mod3Mask
 
workspaces' = map show [1] ++ ["web", "mail", "chat", "code"] ++ map show [6 .. 9 :: Int]
 
layoutHook' =  avoidStruts $ layouts

myManageHook = composeAll . concat $
          [ [ className   =? c                 --> doFloat | c <- myFloats]
          , [ title       =? "VLC (XVideo output)" --> doFloat ]
          , [ title       =? t                 --> doFloat | t <- myOtherFloats]
          , [ resource    =? r                 --> doIgnore | r <- myIgnores]
          , [ className   =? "Firefox-bin"     --> doF (W.shift "web") ]
          , [ className   =? "Opera"           --> doF (W.shift "web") ]
          , [ className   =? "Kopete"          --> doF (W.shift "chat") ]
          ]
          where
              myIgnores       = ["gnome-panel", "desktop_window", "kicker", "KDE Desktop", "KNetworkManager", "KMix", "Power Manager", "KPowersave", "klipper", "knotes", "panel", "stalonetray", "trayer" ] --,"VCLSalFrame" ]
              myFloats        = ["MPlayer", "Gimp", "kdesktop", "mplayer"]
              myOtherFloats   = ["VLC"]
 
layouts =
        smartBorders $ Mirror tiled
    ||| smartBorders Grid
    ||| noBorders Full
    ||| withIM (1%7) (Title "Buddy List") Grid
    ||| withIM (1%7) (((Role "ConversationsWindow"))) Grid
  where
     tiled   = Tall nmaster delta ratio
     nmaster = 2     -- The default number of windows in the master pane
     ratio   = 2%3   -- Default proportion of screen occupied by master pane
     delta   = 3%100 -- Percent of screen to increment by when resizing panes
 
noFollow CrossingEvent {} = return False
noFollow _                = return True
 
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask,                  xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask', xK_p), shellPrompt defaultXPConfig)
    , ((modMask', xK_z), shellPrompt defaultXPConfig)
    , ((modMask', xK_g), windowPromptGoto defaultXPConfig)
    , ((modMask .|. shiftMask  , xK_q     ), restart "xmonad" True)
    , ((modMask', xK_b     ), sendMessage ToggleStruts)
    , ((modMask', xK_v), pasteSelection)
    , ((modMask',               xK_d     ), withFocused (keysResizeWindow (-10,-10) (1,1)))
    , ((modMask',               xK_s     ), withFocused (keysResizeWindow (10,10) (1,1)))
    , ((modMask',               xK_a     ), withFocused (keysMoveWindowTo (512,384) (1, 0)))
    , ((modMask .|. shiftMask, xK_c     ), kill)
    , ((modMask, xK_space ), sendMessage NextLayout)
    , ((modMask, xK_Tab ), windows W.focusDown)
    , ((modMask, xK_j ), windows W.focusDown)
    , ((modMask, xK_k ), windows W.focusUp )
    , ((modMask, xK_h ), sendMessage Shrink)
    , ((modMask, xK_l ), sendMessage Expand)
    , ((modMask, xK_t ), withFocused $ windows . W.sink) 
    , ((modMask , xK_comma ), sendMessage (IncMasterN 1))  
    , ((modMask , xK_period), sendMessage (IncMasterN (-1))) 
    , ((modMask, xK_x), setWMName "LG3D")
    ]
    ++
    -- modMask'-[1..0] %! Switch to workspace N
    -- modMask'-shift-[1..0] %! Move client to workspace N
    [((m .|. modMask', k), windows $ f i)
        | (i, k) <- zip workspaces' $ [xK_1 .. xK_9] ++ [xK_0]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++
    -- modMask'-{e,r} %! Switch to physical/Xinerama screens 1 or 2
    -- modMask'-shift-{e,r} %! Move client to screen 1 or 2
    [((m .|. modMask', key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_e, xK_w, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    [((modMask' .|. mod1Mask, k), windows $ swapWithCurrent i)
        | (i, k) <- zip workspaces' $ [xK_1 .. xK_9] ++ [xK_0]]


myPP h = defaultPP
         { ppCurrent  = dzenColor "white" "#cd8b00" . pad
         , ppVisible  = dzenColor "white" "#666666" . pad
         , ppHidden   = dzenColor "black" "#cccccc" . pad
         , ppHiddenNoWindows = dzenColor "#999999" "#cccccc" . pad
         , ppWsSep    = dzenColor "#bbbbbb" "#cccccc" "^r(1x18)"
         , ppSep      = dzenColor "#bbbbbb" "#cccccc" "^r(1x18)"
         , ppLayout   = dzenColor "black" "#cccccc" .
                        (\ x -> case x of
                                  "TilePrime Horizontal" ->
                                    " ^i(/home/emertens/images/tile_horz.xpm) "
                                  "TilePrime Vertical"   ->
                                    " ^i(/home/emertens/images/tile_vert.xpm) "
                                  "Hinted Full"          ->
                                    " ^i(/home/emertens/images/fullscreen.xpm) "
                                  _                      -> pad x
                        )
         , ppTitle    = (' ':) . escape
         , ppOutput   = hPutStrLn h
         }
  where
  escape = concatMap (\x -> if x == '^' then "^^" else [x])
  pad = wrap " " " "

