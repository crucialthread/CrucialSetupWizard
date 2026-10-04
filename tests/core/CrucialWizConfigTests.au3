#include-once

#include <TestFramework.au3>
#include "..\..\src\core\CrucialSetupWizard.au3"

; #INDEX# =======================================================================================================================
; Title .........: CrucialWizConfigTests.au3
; Version .......: 1.2.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for the Configs region of CrucialSetupWizard.au3.
;                  Tests config map construction, validation, and fallback behavior.
; ===============================================================================================================================
Local $sScriptName = "CrucialWizConfigTests.au3"

; ===============================================================================================================================
; Tests - _NewWndCfg
; ===============================================================================================================================
Func _TestNewWndCfg_DefaultValues()
    _TestFmkHeader("Test: _NewWndCfg() - returns map with default values")

    Local $mCfg = _NewWndCfg()

    _TestFmkAssert($mCfg.iWidth        = $WIN_WIDTH,     "Width is default",        $mCfg.iWidth,        $WIN_WIDTH)
    _TestFmkAssert($mCfg.iHeight       = $WIN_HEIGHT,    "Height is default",       $mCfg.iHeight,       $WIN_HEIGHT)
    _TestFmkAssert($mCfg.iFooterSepY   = $FOOTER_SEP_Y,  "FooterSepY is default",   $mCfg.iFooterSepY,   $FOOTER_SEP_Y)
    _TestFmkAssert($mCfg.iHeaderHeight = $HEADER_H,      "HeaderHeight is default", $mCfg.iHeaderHeight, $HEADER_H)
    _TestFmkAssert($mCfg.iContentTop   = $CONTENT_TOP,   "ContentTop is default",   $mCfg.iContentTop,   $CONTENT_TOP)
    _TestFmkAssert($mCfg.iContentWidth = $CONTENT_W,     "ContentWidth is default", $mCfg.iContentWidth, $CONTENT_W)
EndFunc

Func _TestNewWndCfg_KeywordDefault()
    _TestFmkHeader("Test: _NewWndCfg() - returns map with default values passing keyword Default")

    Local $mCfg = _NewWndCfg(Default, Default, Default, Default, Default, Default)

    _TestFmkAssert($mCfg.iWidth        = $WIN_WIDTH,     "Width is default",        $mCfg.iWidth,        $WIN_WIDTH)
    _TestFmkAssert($mCfg.iHeight       = $WIN_HEIGHT,    "Height is default",       $mCfg.iHeight,       $WIN_HEIGHT)
    _TestFmkAssert($mCfg.iFooterSepY   = $FOOTER_SEP_Y,  "FooterSepY is default",   $mCfg.iFooterSepY,   $FOOTER_SEP_Y)
    _TestFmkAssert($mCfg.iHeaderHeight = $HEADER_H,      "HeaderHeight is default", $mCfg.iHeaderHeight, $HEADER_H)
    _TestFmkAssert($mCfg.iContentTop   = $CONTENT_TOP,   "ContentTop is default",   $mCfg.iContentTop,   $CONTENT_TOP)
    _TestFmkAssert($mCfg.iContentWidth = $CONTENT_W,     "ContentWidth is default", $mCfg.iContentWidth, $CONTENT_W)
EndFunc

Func _TestNewWndCfg_CustomValues()
    _TestFmkHeader("Test: _NewWndCfg() - returns map with custom values")

    Local $mCfg = _NewWndCfg(600, 400, 340, 80, 90, 560)

    _TestFmkAssert($mCfg.iWidth        = 600, "Width is custom",        $mCfg.iWidth,        600)
    _TestFmkAssert($mCfg.iHeight       = 400, "Height is custom",       $mCfg.iHeight,       400)
    _TestFmkAssert($mCfg.iFooterSepY   = 340, "FooterSepY is custom",   $mCfg.iFooterSepY,   340)
    _TestFmkAssert($mCfg.iHeaderHeight = 80,  "HeaderHeight is custom", $mCfg.iHeaderHeight, 80)
    _TestFmkAssert($mCfg.iContentTop   = 90,  "ContentTop is custom",   $mCfg.iContentTop,   90)
    _TestFmkAssert($mCfg.iContentWidth = 560, "ContentWidth is custom", $mCfg.iContentWidth, 560)
EndFunc

Func _TestNewWndCfg_FooterSepYAdjustsWithHeight()
    _TestFmkHeader("Test: _NewWndCfg() - FooterSepY recalculates against a custom Height when left default")

    Local $mCfg = _NewWndCfg(Default, 500)

    _TestFmkAssert($mCfg.iFooterSepY = 500 - $FOOTER_SEP_Y_OFFSET, "FooterSepY adjusts with Height", $mCfg.iFooterSepY, 500 - $FOOTER_SEP_Y_OFFSET)
EndFunc

Func _TestNewWndCfg_ContentWidthAdjustsWithWidth()
    _TestFmkHeader("Test: _NewWndCfg() - ContentWidth recalculates against a custom Width when left default")

    Local $mCfg = _NewWndCfg(700)

    _TestFmkAssert($mCfg.iContentWidth = 700 - $CONTENT_W_OFFSET, "ContentWidth adjusts with Width", $mCfg.iContentWidth, 700 - $CONTENT_W_OFFSET)
EndFunc

Func _TestNewWndCfg_ContentTopAdjustsWithHeaderHeight()
    _TestFmkHeader("Test: _NewWndCfg() - ContentTop recalculates against a custom HeaderHeight when left default")

    Local $mCfg = _NewWndCfg(Default, Default, Default, 100)

    _TestFmkAssert($mCfg.iContentTop = 100 + $CONTENT_TOP_OFFSET, "ContentTop adjusts with HeaderHeight", $mCfg.iContentTop, 100 + $CONTENT_TOP_OFFSET)
EndFunc

Func _TestNewWndCfg_FooterSepYExplicitOverrideWinsOverHeight()
    _TestFmkHeader("Test: _NewWndCfg() - explicit FooterSepY is not recalculated even with a custom Height")

    Local $mCfg = _NewWndCfg(Default, 500, 999)

    _TestFmkAssert($mCfg.iFooterSepY = 999, "Explicit FooterSepY wins over Height", $mCfg.iFooterSepY, 999)
EndFunc

Func _TestNewWndCfg_ContentWidthExplicitOverrideWinsOverWidth()
    _TestFmkHeader("Test: _NewWndCfg() - explicit ContentWidth is not recalculated even with a custom Width")

    Local $mCfg = _NewWndCfg(700, Default, Default, Default, Default, 888)

    _TestFmkAssert($mCfg.iContentWidth = 888, "Explicit ContentWidth wins over Width", $mCfg.iContentWidth, 888)
EndFunc

Func _TestNewWndCfg_ContentTopExplicitOverrideWinsOverHeaderHeight()
    _TestFmkHeader("Test: _NewWndCfg() - explicit ContentTop is not recalculated even with a custom HeaderHeight")

    Local $mCfg = _NewWndCfg(Default, Default, Default, 100, 777)

    _TestFmkAssert($mCfg.iContentTop = 777, "Explicit ContentTop wins over HeaderHeight", $mCfg.iContentTop, 777)
EndFunc

; ===============================================================================================================================
; Tests - _NewFontCfg
; ===============================================================================================================================
Func _TestNewFontCfg_DefaultValues()
    _TestFmkHeader("Test: _NewFontCfg() - returns map with default values")

    Local $mCfg = _NewFontCfg()

    _TestFmkAssert($mCfg.sName = $FONT_NAME, "Name is default", $mCfg.sName, $FONT_NAME)
    _TestFmkAssert($mCfg.iSize = $FONT_SIZE, "Size is default", $mCfg.iSize, $FONT_SIZE)
EndFunc

Func _TestNewFontCfg_KeywordDefault()
    _TestFmkHeader("Test: _NewFontCfg() - returns map with default values passing keyword Default")

    Local $mCfg = _NewFontCfg(Default, Default)

    _TestFmkAssert($mCfg.sName = $FONT_NAME, "Name is default", $mCfg.sName, $FONT_NAME)
    _TestFmkAssert($mCfg.iSize = $FONT_SIZE, "Size is default", $mCfg.iSize, $FONT_SIZE)
EndFunc

Func _TestNewFontCfg_CustomValues()
    _TestFmkHeader("Test: _NewFontCfg() - returns map with custom values")

    Local $mCfg = _NewFontCfg("Arial", 14)

    _TestFmkAssert($mCfg.sName = "Arial", "Name is custom", $mCfg.sName, "Arial")
    _TestFmkAssert($mCfg.iSize = 14,      "Size is custom", $mCfg.iSize, 14)
EndFunc

; ===============================================================================================================================
; Tests - _NewBtnDim
; ===============================================================================================================================
Func _TestNewBtnDim_DefaultValues()
    _TestFmkHeader("Test: _NewBtnDim() - returns map with default values")

    Local $mCfg = _NewBtnDim()

    _TestFmkAssert($mCfg.iWidth  = $BTN_W,   "Width is default",  $mCfg.iWidth,  $BTN_W)
    _TestFmkAssert($mCfg.iHeight = $BTN_H,   "Height is default", $mCfg.iHeight, $BTN_H)
    _TestFmkAssert($mCfg.iGap    = $BTN_GAP, "Gap is default",    $mCfg.iGap,    $BTN_GAP)
    _TestFmkAssert($mCfg.iYaxis  = $BTN_Y,   "Y is default",      $mCfg.iYaxis,  $BTN_Y)
EndFunc

Func _TestNewBtnDim_KeywordDefault()
    _TestFmkHeader("Test: _NewBtnDim() - returns map with default values passing keyword Default")

    Local $mCfg = _NewBtnDim(Default, Default, Default, Default)

    _TestFmkAssert($mCfg.iWidth  = $BTN_W,   "Width is default",  $mCfg.iWidth,  $BTN_W)
    _TestFmkAssert($mCfg.iHeight = $BTN_H,   "Height is default", $mCfg.iHeight, $BTN_H)
    _TestFmkAssert($mCfg.iGap    = $BTN_GAP, "Gap is default",    $mCfg.iGap,    $BTN_GAP)
    _TestFmkAssert($mCfg.iYaxis  = $BTN_Y,   "Y is default",      $mCfg.iYaxis,  $BTN_Y)
EndFunc

Func _TestNewBtnDim_CustomValues()
    _TestFmkHeader("Test: _NewBtnDim() - returns map with custom values")

    Local $mCfg = _NewBtnDim(150, 40, 15, 280)

    _TestFmkAssert($mCfg.iWidth  = 150, "Width is custom",  $mCfg.iWidth,  150)
    _TestFmkAssert($mCfg.iHeight = 40,  "Height is custom", $mCfg.iHeight, 40)
    _TestFmkAssert($mCfg.iGap    = 15,  "Gap is custom",    $mCfg.iGap,    15)
    _TestFmkAssert($mCfg.iYaxis  = 280, "Y is custom",      $mCfg.iYaxis,  280)
EndFunc

; ===============================================================================================================================
; Tests - _NewBtnCaptions
; ===============================================================================================================================
Func _TestNewBtnCaptions_DefaultValues()
    _TestFmkHeader("Test: _NewBtnCaptions() - returns map with default values")

    Local $mCfg = _NewBtnCaptions()

    _TestFmkAssert($mCfg.sNext   = $BTN_CAPTION_NEXT,   "Next is default",   $mCfg.sNext,   $BTN_CAPTION_NEXT)
    _TestFmkAssert($mCfg.sBack   = $BTN_CAPTION_BACK,   "Back is default",   $mCfg.sBack,   $BTN_CAPTION_BACK)
    _TestFmkAssert($mCfg.sCancel = $BTN_CAPTION_CANCEL, "Cancel is default", $mCfg.sCancel, $BTN_CAPTION_CANCEL)
    _TestFmkAssert($mCfg.sFinish = $BTN_CAPTION_FINISH, "Finish is default", $mCfg.sFinish, $BTN_CAPTION_FINISH)
    _TestFmkAssert($mCfg.sApply  = $BTN_CAPTION_APPLY,  "Apply is default",  $mCfg.sApply,  $BTN_CAPTION_APPLY)
EndFunc

Func _TestNewBtnCaptions_KeywordDefault()
    _TestFmkHeader("Test: _NewBtnCaptions() - returns map with default values passing keyword Default")

    Local $mCfg = _NewBtnCaptions(Default, Default, Default, Default, Default)

    _TestFmkAssert($mCfg.sNext   = $BTN_CAPTION_NEXT,   "Next is default",   $mCfg.sNext,   $BTN_CAPTION_NEXT)
    _TestFmkAssert($mCfg.sBack   = $BTN_CAPTION_BACK,   "Back is default",   $mCfg.sBack,   $BTN_CAPTION_BACK)
    _TestFmkAssert($mCfg.sCancel = $BTN_CAPTION_CANCEL, "Cancel is default", $mCfg.sCancel, $BTN_CAPTION_CANCEL)
    _TestFmkAssert($mCfg.sFinish = $BTN_CAPTION_FINISH, "Finish is default", $mCfg.sFinish, $BTN_CAPTION_FINISH)
    _TestFmkAssert($mCfg.sApply  = $BTN_CAPTION_APPLY,  "Apply is default",  $mCfg.sApply,  $BTN_CAPTION_APPLY)
EndFunc

Func _TestNewBtnCaptions_CustomValues()
    _TestFmkHeader("Test: _NewBtnCaptions() - returns map with custom values")

    Local $mCfg = _NewBtnCaptions("Forward", "Backward", "Exit", "Done", "Apply")

    _TestFmkAssert($mCfg.sNext   = "Forward",  "Next is custom",   $mCfg.sNext,   "Forward")
    _TestFmkAssert($mCfg.sBack   = "Backward", "Back is custom",   $mCfg.sBack,   "Backward")
    _TestFmkAssert($mCfg.sCancel = "Exit",     "Cancel is custom", $mCfg.sCancel, "Exit")
    _TestFmkAssert($mCfg.sFinish = "Done",     "Finish is custom", $mCfg.sFinish, "Done")
    _TestFmkAssert($mCfg.sApply  = "Apply",    "Apply is custom",  $mCfg.sApply,  "Apply")
EndFunc

; ===============================================================================================================================
; Tests - _NewBtnCfg
; ===============================================================================================================================
Func _TestNewBtnCfg_DefaultValues()
    _TestFmkHeader("Test: _NewBtnCfg() - returns map with default dim and caption submaps")

    Local $mCfg = _NewBtnCfg()

    _TestFmkAssert(IsMap($mCfg.mDim),  "Dim is a map",  IsMap($mCfg.mDim),  True)
    _TestFmkAssert(IsMap($mCfg.mCapt), "Capt is a map", IsMap($mCfg.mCapt), True)
    _TestFmkAssert($mCfg.mDim.iWidth   = $BTN_W,            "Dim width is default", $mCfg.mDim.iWidth,   $BTN_W)
    _TestFmkAssert($mCfg.mCapt.sNext   = $BTN_CAPTION_NEXT, "Capt next is default", $mCfg.mCapt.sNext,   $BTN_CAPTION_NEXT)
EndFunc

Func _TestNewBtnCfg_FallsBackOnInvalidDim()
    _TestFmkHeader("Test: _NewBtnCfg() - falls back to defaults when invalid dim provided")

    Local $mCfg = _NewBtnCfg("invalid dim", _NewBtnCaptions())

    _TestFmkAssert($mCfg.mDim.iWidth = $BTN_W, "Dim falls back to default", $mCfg.mDim.iWidth, $BTN_W)
EndFunc

Func _TestNewBtnCfg_FallsBackOnInvalidCapt()
    _TestFmkHeader("Test: _NewBtnCfg() - falls back to defaults when invalid captions provided")

    Local $mCfg = _NewBtnCfg(_NewBtnDim(), "invalid captions")

    _TestFmkAssert($mCfg.mCapt.sNext = $BTN_CAPTION_NEXT, "Capt falls back to default", $mCfg.mCapt.sNext, $BTN_CAPTION_NEXT)
EndFunc

; ===============================================================================================================================
; Tests - _NewInstallerCfg
; ===============================================================================================================================
Func _TestNewInstallerCfg_DefaultValues()
    _TestFmkHeader("Test: _NewInstallerCfg() - returns flat map with all required keys")

    Local $mCfg = _NewInstallerCfg()

    _TestFmkAssert($mCfg.iWndWidth    = $WIN_WIDTH,          "iWndWidth is default",    $mCfg.iWndWidth,    $WIN_WIDTH)
    _TestFmkAssert($mCfg.iWndHeight   = $WIN_HEIGHT,         "iWndHeight is default",   $mCfg.iWndHeight,   $WIN_HEIGHT)
    _TestFmkAssert($mCfg.sFontName    = $FONT_NAME,          "sFontName is default",    $mCfg.sFontName,    $FONT_NAME)
    _TestFmkAssert($mCfg.iFontSize    = $FONT_SIZE,          "iFontSize is default",    $mCfg.iFontSize,    $FONT_SIZE)
    _TestFmkAssert($mCfg.iBtnWidth    = $BTN_W,              "iBtnWidth is default",    $mCfg.iBtnWidth,    $BTN_W)
    _TestFmkAssert($mCfg.iBtnY        = $BTN_Y,              "iBtnY is default",        $mCfg.iBtnY,        $BTN_Y)
    _TestFmkAssert($mCfg.sBtnCaptNext = $BTN_CAPTION_NEXT,   "sBtnCaptNext is default", $mCfg.sBtnCaptNext, $BTN_CAPTION_NEXT)
EndFunc

Func _TestNewInstallerCfg_FallsBackOnInvalidWnd()
    _TestFmkHeader("Test: _NewInstallerCfg() - falls back to default wnd config when invalid")

    Local $mCfg = _NewInstallerCfg("Invalid Wnd Configs", _NewFontCfg(), _NewBtnCfg())

    _TestFmkAssert($mCfg.iWndWidth = $WIN_WIDTH, "WndWidth falls back", $mCfg.iWndWidth, $WIN_WIDTH)
EndFunc

Func _TestNewInstallerCfg_FallsBackOnInvalidFont()
    _TestFmkHeader("Test: _NewInstallerCfg() - falls back to default font config when invalid")

    Local $mCfg = _NewInstallerCfg(_NewWndCfg(), "Invalid Font Configs", _NewBtnCfg())

    _TestFmkAssert($mCfg.sFontName = $FONT_NAME, "FontName falls back", $mCfg.sFontName, $FONT_NAME)
EndFunc

Func _TestNewInstallerCfg_FallsBackOnInvalidBtn()
    _TestFmkHeader("Test: _NewInstallerCfg() - falls back to default btn config when invalid")

    Local $mCfg = _NewInstallerCfg(_NewWndCfg(), _NewFontCfg(), "Invalid Btn Configs")

    _TestFmkAssert($mCfg.iBtnWidth = $BTN_W, "BtnWidth falls back", $mCfg.iBtnWidth, $BTN_W)
EndFunc

Func _TestNewInstallerCfg_BtnYAdjustsWithWndHeight()
    _TestFmkHeader("Test: _NewInstallerCfg() - BtnY recalculates against a custom window height when left default")

    Local $mWndCfg = _NewWndCfg(Default, 500)
    Local $mCfg = _NewInstallerCfg($mWndCfg)

    _TestFmkAssert($mCfg.iBtnY = 500 - $BTN_Y_OFFSET, "BtnY adjusts with window height", $mCfg.iBtnY, 500 - $BTN_Y_OFFSET)
EndFunc

Func _TestNewInstallerCfg_BtnYExplicitOverrideWinsOverWndHeight()
    _TestFmkHeader("Test: _NewInstallerCfg() - explicit BtnY is not recalculated even with a custom window height")

    Local $mWndCfg = _NewWndCfg(Default, 500)
    Local $mBtnCfg = _NewBtnCfg(_NewBtnDim(Default, Default, Default, 999))
    Local $mCfg = _NewInstallerCfg($mWndCfg, Default, $mBtnCfg)

    _TestFmkAssert($mCfg.iBtnY = 999, "Explicit BtnY wins over window height", $mCfg.iBtnY, 999)
EndFunc

; ===============================================================================================================================
; Tests - __IsValidInstallerCfg
; ===============================================================================================================================
Func _TestIsValidInstallerCfg_ValidConfig()
    _TestFmkHeader("Test: __IsValidInstallerCfg() - returns True for valid config")

    Local $mCfg = _NewInstallerCfg()

    _TestFmkAssert(__IsValidInstallerCfg($mCfg) = True, "Valid config returns True", __IsValidInstallerCfg($mCfg), True)
EndFunc

Func _TestIsValidInstallerCfg_EmptyMap()
    _TestFmkHeader("Test: __IsValidInstallerCfg() - returns False for empty map")

    Local $mCfg[]

    _TestFmkAssert(__IsValidInstallerCfg($mCfg) = False, "Empty map returns False", __IsValidInstallerCfg($mCfg), False)
EndFunc

Func _TestIsValidInstallerCfg_MissingKey()
    _TestFmkHeader("Test: __IsValidInstallerCfg() - returns False when a required key is missing")

    Local $mCfg = _NewInstallerCfg()
    MapRemove($mCfg, "iWndWidth")

    _TestFmkAssert(__IsValidInstallerCfg($mCfg) = False, "Missing key returns False", __IsValidInstallerCfg($mCfg), False)
EndFunc

Func _TestIsValidInstallerCfg_InvalidType()
    _TestFmkHeader("Test: __IsValidInstallerCfg() - returns False when a key has wrong type")

    Local $mCfg = _NewInstallerCfg()
    $mCfg.iWndWidth = "not a number"

    _TestFmkAssert(__IsValidInstallerCfg($mCfg) = False, "Wrong type returns False", __IsValidInstallerCfg($mCfg), False)
EndFunc

; ===============================================================================================================================
; Run tests
; ===============================================================================================================================
Func __RunCrucialWizConfigTest_NewWndCfg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewWndCfg_DefaultValues, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_KeywordDefault, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_CustomValues,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_FooterSepYAdjustsWithHeight, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_ContentWidthAdjustsWithWidth, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_ContentTopAdjustsWithHeaderHeight, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_FooterSepYExplicitOverrideWinsOverHeight, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_ContentWidthExplicitOverrideWinsOverWidth, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewWndCfg_ContentTopExplicitOverrideWinsOverHeaderHeight, $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_NewFontCfg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewFontCfg_DefaultValues, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewFontCfg_KeywordDefault, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewFontCfg_CustomValues,  $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_NewBtnDim(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewBtnDim_DefaultValues, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnDim_KeywordDefault, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnDim_CustomValues,  $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_NewBtnCaptions(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewBtnCaptions_DefaultValues, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnCaptions_KeywordDefault, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnCaptions_CustomValues,  $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_NewBtnCfg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewBtnCfg_DefaultValues, 		 $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnCfg_FallsBackOnInvalidDim,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewBtnCfg_FallsBackOnInvalidCapt, $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_NewInstallerCfg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestNewInstallerCfg_DefaultValues, 		   $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewInstallerCfg_FallsBackOnInvalidWnd,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewInstallerCfg_FallsBackOnInvalidFont, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewInstallerCfg_FallsBackOnInvalidBtn,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewInstallerCfg_BtnYAdjustsWithWndHeight, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestNewInstallerCfg_BtnYExplicitOverrideWinsOverWndHeight, $bAllPassed)
EndFunc

Func __RunCrucialWizConfigTest_IsValidInstallerCfg(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsValidInstallerCfg_ValidConfig, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidInstallerCfg_EmptyMap, 	$bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidInstallerCfg_MissingKey, 	$bAllPassed)
	$bAllPassed = _TestFmkRun(_TestIsValidInstallerCfg_InvalidType, $bAllPassed)
EndFunc

Func _RunCrucialWizConfigTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialWizConfigTest_NewWndCfg($bAllPassed)
    __RunCrucialWizConfigTest_NewFontCfg($bAllPassed)
	__RunCrucialWizConfigTest_NewBtnDim($bAllPassed)
	__RunCrucialWizConfigTest_NewBtnCaptions($bAllPassed)
	__RunCrucialWizConfigTest_NewBtnCfg($bAllPassed)
	__RunCrucialWizConfigTest_NewInstallerCfg($bAllPassed)
	__RunCrucialWizConfigTest_IsValidInstallerCfg($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc
_TestFmkRunAllTests(_RunCrucialWizConfigTests, $sScriptName)
