#include <TestFramework.au3>
#include <StubConstants.au3>
#include "..\..\src\installer\CrucialSetupWizardUninstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialWizUninstallerTests.au3
; Version .......: 1.1.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for CrucialSetupWizardUninstaller.au3.
;                  Tests install record reading, registry and folder cleanup,
;                  uninstall logic, and wizard setup.
; ===============================================================================================================================
Local Const $TST_WIZ_UNINSTALLER_TESTS = "CrucialWizUninstallerTests.au3"

;================================================================================================================================
#Region ; Tests - __ReadInstallRecord
;================================================================================================================================

Func _TestReadInstallRecord_Success()
    _TestFmkHeader("Test: __ReadInstallRecord() - reads paths from registry and returns True")

	Local $sIncludePath = "C:\AutoIt3\Include\Vendor"
    Local $sInstallPath = "C:\AutoIt3\TestFramework"
    _SetStubReturn("RegRead", $_1st, $sIncludePath)
    _SetStubReturn("RegRead", $_2nd, $sInstallPath)

    $g_sIncludePath = ""
	$g_sInstallPath = ""
    Local $bResult = __ReadInstallRecord()
	Local $sRegIncludeName = _GetStubCall("RegRead", $_1st, $Param_ValueName)
	Local $sRegInstallName = _GetStubCall("RegRead", $_2nd, $Param_ValueName)

    _TestFmkAssert($bResult = True,                  "Returns True",               	  $bResult,         True, 		   $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($g_sIncludePath  = $sIncludePath, "IncludePath set correctly",  	  $g_sIncludePath,  $sIncludePath, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($g_sInstallPath  = $sInstallPath, "InstallPath set correctly",  	  $g_sInstallPath,  $sInstallPath, $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($sRegIncludeName = "IncludePath", "Correct IncludePath Registry ", $sRegIncludeName, "IncludePath", $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($sRegInstallName = "InstallPath", "Correct InstallPath Registry ", $sRegInstallName, "InstallPath", $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestReadInstallRecord_IncludePathMissing()
    _TestFmkHeader("Test: __ReadInstallRecord() - returns False when IncludePath missing from registry")

    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)

    Local $bResult = __ReadInstallRecord()

    _TestFmkAssert($bResult = False, "Returns False when IncludePath missing", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestReadInstallRecord_InstallPathMissing()
    _TestFmkHeader("Test: __ReadInstallRecord() - returns False when InstallPath missing from registry")

    _SetStubReturn("RegRead", $_1st, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegRead", $_2nd, $STUB_ERROR)

    Local $bResult = __ReadInstallRecord()

    _TestFmkAssert($bResult = False, "Returns False when InstallPath missing", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __IsRunningFromInstallFolder
;================================================================================================================================

Func _TestIsRunningFromInstallFolder_True()
    _TestFmkHeader("Test: __IsRunningFromInstallFolder() - returns True when running from install folder")

	$g_sInstallPath = @ScriptFullPath
    Local $bResult = __IsRunningFromInstallFolder()

    _TestFmkAssert($bResult > 0, "Returns True when in install folder", $bResult > 0, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestIsRunningFromInstallFolder_False()
    _TestFmkHeader("Test: __IsRunningFromInstallFolder() - returns False when not running from install folder")

    $g_sInstallPath = "C:\SomeOther\Folder"

    Local $bResult = __IsRunningFromInstallFolder()

    _TestFmkAssert($bResult = 0, "Returns False when not in install folder", $bResult, 0, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RelaunchFromTemp
;================================================================================================================================

Func _TestRelaunchFromTemp_CopiesAndLaunches()
    _TestFmkHeader("Test: __RelaunchFromTemp() - copies exe to temp and launches it")

    __RelaunchFromTemp()

    Local $sTempExe      = @TempDir & "\CrucialSetupWizardUninstaller.exe"
    Local $sCopyDest     = _GetStubCall("FileCopy",     $_1st, $Param_Dest)
    Local $sShellExecute = _GetStubCall("ShellExecute", $_1st, $Param_Filename)
    _TestFmkAssert($sCopyDest     = $sTempExe, "Copied to temp folder",      $sCopyDest,     $sTempExe, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($sShellExecute = $sTempExe, "Launched from temp folder",  $sShellExecute, $sTempExe, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RemoveIncludeRegistry
;================================================================================================================================

Func _TestRemoveIncludeRegistry_RemovesOnlyTFWPath()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - removes only TestFramework path leaving others intact")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",  $_1st, "C:\OtherVendor;C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegWrite", $_1st, 1)

	_Try()
		__RemoveIncludeRegistry()
	_EndTry()

    Local $sWritten = _GetStubCall("RegWrite", $_1st, $Param_Value)
    _TestFmkAssert($sWritten = "C:\OtherVendor", "Only TestFramework path removed", $sWritten, "C:\OtherVendor", $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_DeletesKeyWhenOnlyTFWPath()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - deletes registry key when TestFramework is the only path")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",   $_1st, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegDelete", $_1st, 1)

	_Try()
		__RemoveIncludeRegistry()
		Local $ex
		Local $bExceptionThrown = _Catch($ex) ? True : False
	_EndTry()

    _TestFmkAssert(_StubCallCount("RegDelete") = 1, "RegDelete called",    _StubCallCount("RegDelete"), 1, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert(_StubCallCount("RegWrite")  = 0, "RegWrite not called", _StubCallCount("RegWrite"),  0, $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False, 		"No exception thrown", $bExceptionThrown,  		False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_DoesNothingWhenMissing()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - does nothing when registry key missing")

    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)

	_Try()
		__RemoveIncludeRegistry()
		Local $ex
		Local $bExceptionThrown = _Catch($ex) ? True : False
	_EndTry()

    _TestFmkAssert(_StubCallCount("RegDelete") = 0, "RegDelete not called", _StubCallCount("RegDelete"), 0, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert(_StubCallCount("RegWrite")  = 0, "RegWrite not called",  _StubCallCount("RegWrite"),  0, $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False, 		"No exception thrown",  $bExceptionThrown,  	 False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_ErrorOnRegDeleteFailure()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - sets @error when RegDelete() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",   $_1st, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegDelete", $_1st, 0)

	Local $bResult = __RemoveIncludeRegistry()
	Local $iErr    = @error

    _TestFmkAssert($bResult = False, "Returns False on RegDelete failure", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($iErr > 0,        "Sets @error on RegDelete failure",   $iErr > 0, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_ErrorOnRegWriteFailure()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - sets @error when RegWrite() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",  $_1st, "C:\OtherVendor;C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegWrite", $_1st, 0)

	Local $bResult = __RemoveIncludeRegistry()
	Local $iErr    = @error

    _TestFmkAssert($bResult = False, "Returns False on RegWrite failure", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($iErr > 0,        "Sets @error on RegWrite failure",   $iErr > 0, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_ThrowsOnRegDeleteFailure()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - thrown expected exception when RegDelete() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",   $_1st, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegDelete", $_1st, 0)

    _Try()
        Local $bResult = __RemoveIncludeRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("RegDeleteException")) ? True : False
    _EndTry()

	_TestFmkAssert($bExceptionThrown = True, """RegDeleteException"" type thrown", $bExceptionThrown, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveIncludeRegistry_ThrowsOnRegWriteFailure()
    _TestFmkHeader("Test: __RemoveIncludeRegistry() - thrown expected exception when RegWrite() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead",  $_1st, "C:\OtherVendor;C:\AutoIt3\Include\Vendor")
    _SetStubReturn("RegWrite", $_1st, 0)

    _Try()
        Local $bResult = __RemoveIncludeRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("RegWriteException")) ? True : False
    _EndTry()

	_TestFmkAssert($bExceptionThrown = True, """RegWriteException"" type thrown", $bExceptionThrown, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RemoveFolderIfEmpty
;================================================================================================================================

Func _TestRemoveFolderIfEmpty_RemovesWhenEmpty()
    _TestFmkHeader("Test: __RemoveFolderIfEmpty() - removes folder when it is empty")

    Local $aSize[3] = [0, 0, 0]
    _SetStubReturn("DirGetSize", $_1st, $aSize)
    _SetStubReturn("DirRemove",  $_1st, 1)

    _Try()
        __RemoveFolderIfEmpty("C:\AutoIt3\Include\Vendor")
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
    _EndTry()

    _TestFmkAssert(_StubCallCount("DirRemove") = 1, "DirRemove called",    _StubCallCount("DirRemove"), 1, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($bExceptionThrown = False,       "No exception thrown", $bExceptionThrown, False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveFolderIfEmpty_DoesNotRemoveWhenNotEmpty()
    _TestFmkHeader("Test: __RemoveFolderIfEmpty() - does not remove folder when it has files")

    Local $aSize[3] = [1024, 5, 0]
    _SetStubReturn("DirGetSize", $_1st, $aSize)

	_Try()
		__RemoveFolderIfEmpty("C:\AutoIt3\Include\Vendor")
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
	_EndTry()

    _TestFmkAssert(_StubCallCount("DirRemove") = 0, "DirRemove not called", _StubCallCount("DirRemove"), 0, $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False,       "No exception thrown", $bExceptionThrown, False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveFolderIfEmpty_DoesNothingWhenFolderMissing()
    _TestFmkHeader("Test: __RemoveFolderIfEmpty() - does nothing when folder does not exist")

    _SetStubReturn("DirGetSize", $_1st, $STUB_ERROR)

    _Try()
        __RemoveFolderIfEmpty("C:\NonExistent\Folder")
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
    _EndTry()

    _TestFmkAssert(_StubCallCount("DirRemove") = 0, "DirRemove not called",  _StubCallCount("DirRemove"), 0, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($bExceptionThrown = False,       "No exception thrown",   $bExceptionThrown, False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveFolderIfEmpty_ErrorOnDirRemoveFailure()
    _TestFmkHeader("Test: __RemoveFolderIfEmpty() - sets @error when DirRemove() fails")

    Local $aSize[3] = [0, 0, 0]
    _SetStubReturn("DirGetSize", $_1st, $aSize)
    _SetStubReturn("DirRemove",  $_1st, 0)

	Local $bResult = __RemoveFolderIfEmpty("C:\AutoIt3\Include\Vendor")
	Local $iErr    = @error

    _TestFmkAssert($bResult = False, "Returns False on DirRemove failure", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($iErr > 0,        "Sets @error on DirRemove failure",   $iErr > 0, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveFolderIfEmpty_ThrowsOnDirRemoveFailure()
    _TestFmkHeader("Test: __RemoveFolderIfEmpty() - thrown expected exception when DirRemove() fails")

    Local $aSize[3] = [0, 0, 0]
    _SetStubReturn("DirGetSize", $_1st, $aSize)
    _SetStubReturn("DirRemove",  $_1st, 0)

    _Try()
        Local $bResult = __RemoveFolderIfEmpty("C:\AutoIt3\Include\Vendor")
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("RemoveFolderException")) ? True : False
    _EndTry()

	_TestFmkAssert($bExceptionThrown = True, """RemoveFolderException"" type thrown", $bExceptionThrown, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RemoveInstalledFile
;================================================================================================================================

Func _TestRemoveInstalledFile_ReturnsTrueOnSuccess()
    _TestFmkHeader("Test: __RemoveInstalledFile() - returns True when file deleted successfully")

    _SetStubReturn("FileExists", $_1st, True)
    _SetStubReturn("FileDelete", $_1st, 1)

    Local $bResult = __RemoveInstalledFile("C:\AutoIt3\Include\Vendor\TestFramework.au3")

    _TestFmkAssert($bResult = True, "Returns True on success", $bResult, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveInstalledFile_SetErrorOnFailure()
    _TestFmkHeader("Test: __RemoveInstalledFile() - sets @error and returns False when FileDelete() fails")

    _SetStubReturn("FileExists", $_1st, True)
    _SetStubReturn("FileDelete", $_1st, 0)

	Local $bResult = __RemoveInstalledFile("C:\AutoIt3\Include\Vendor\TestFramework.au3")
	Local $iErr    = @error

    _TestFmkAssert($bResult = False, "Returns False on failure", $bResult, False, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($iErr > 0,        "Sets @error on failure",   $iErr > 0, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveInstalledFile_ThrowsOnFailure()
    _TestFmkHeader("Test: __RemoveInstalledFile() - thrown expected exception when FileDelete() fails")

    _SetStubReturn("FileExists", $_1st, True)
    _SetStubReturn("FileDelete", $_1st, 0)

    _Try()
		__RemoveInstalledFile("C:\AutoIt3\Include\Vendor\TestFramework.au3")
        Local $e
        Local $bExceptionThrown = _Catch($e, _AsExceptionType("RemoveFileException")) ? True : False
    _EndTry()

	_TestFmkAssert($bExceptionThrown = True, """RemoveFileException"" type thrown", $bExceptionThrown, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveInstalledFile_CallsFileDelete()
    _TestFmkHeader("Test: __RemoveInstalledFile() - calls FileDelete with correct path")

    Local $sFilePath = "C:\AutoIt3\Include\Vendor\TestFramework.au3"
    _SetStubReturn("FileExists", $_1st, True)
    _SetStubReturn("FileDelete", $_1st, 1)

    __RemoveInstalledFile($sFilePath)

    Local $sDeleted = _GetStubCall("FileDelete", $_1st, $Param_Filename)
    _TestFmkAssert($sDeleted = $sFilePath, "FileDelete called with correct path", $sDeleted, $sFilePath, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRemoveInstalledFile_SkipsWhenFileNotExists()
    _TestFmkHeader("Test: __RemoveInstalledFile() - skips silently when file does not exist")

    _SetStubReturn("FileExists", $_1st, False)

    _Try()
        Local $bResult = __RemoveInstalledFile("C:\AutoIt3\Include\Vendor\TestFramework.au3")
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
    _EndTry()

    _TestFmkAssert(_StubCallCount("FileDelete") = 0, "FileDelete not called",  _StubCallCount("FileDelete"), 0, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($bExceptionThrown = False,        "No exception thrown",     $bExceptionThrown,       False, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RunUninstall
;================================================================================================================================

Func _TestRunUninstall_ReturnsTrueOnSuccess()
    _TestFmkHeader("Test: __RunUninstall() - returns True when all steps succeed")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\TestFramework"

    Local $aEmptySize[3] = [0, 0, 0]
    _SetStubReturn("RegRead",    $_1st, "C:\AutoIt3\Include\Vendor") ; __RemoveIncludeRegistry - only TFW path
    _SetStubReturn("RegDelete",  $_1st, 1)                           ; __RemoveIncludeRegistry - delete include key
    _SetStubReturn("DirGetSize", $_1st, $aEmptySize)                 ; __RemoveFolderIfEmpty for IncludePath - empty, remove
    _SetStubReturn("DirRemove",  $_1st, 1)                           ; IncludePath folder removed
    _SetStubReturn("DirGetSize", $_2nd, $aEmptySize)                 ; __RemoveFolderIfEmpty for InstallPath - empty, remove
    _SetStubReturn("DirRemove",  $_2nd, 1)                           ; InstallPath folder removed
    _SetStubReturn("RegDelete",  $_2nd, 1)                           ; REG_INSTALL_KEY
    _SetStubReturn("RegDelete",  $_3rd, 1)                           ; REG_UNINSTALL_KEY

    Local $bResult = __RunUninstall(10, 11)

    Local $sIncludeRegKey   = _GetStubCall("RegDelete", $_1st, $Param_Keyname)
    Local $sInstallRegKey   = _GetStubCall("RegDelete", $_2nd, $Param_Keyname)
    Local $sUninstallRegKey = _GetStubCall("RegDelete", $_3rd, $Param_Keyname)

    _TestFmkAssert($bResult = True,                        "Returns True on success",           $bResult,                         True, 				  $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert(_StubCallCount("FileDelete") = 4,       "All 4 files deleted",               _StubCallCount("FileDelete"),     4, 				  $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($sIncludeRegKey  = $REG_AUTOIT_INCLUDE, "Include registry key deleted",      $sIncludeRegKey, 				  $REG_AUTOIT_INCLUDE, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert(_StubCallCount("DirRemove")  = 2,       "Both folders removed",              _StubCallCount("DirRemove"),      2, 				  $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($sInstallRegKey  = $REG_INSTALL_KEY,    "Install registry key deleted",      $sInstallRegKey,                  $REG_INSTALL_KEY, 	  $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($sUninstallRegKey = $REG_UNINSTALL_KEY, "Uninstall registry key deleted",    $sUninstallRegKey,                $REG_UNINSTALL_KEY,  $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert(_StubCallCount("GUICtrlSetData") = 14,  "Progress updated for all steps", 	_StubCallCount("GUICtrlSetData"), 14, 				  $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

Func _TestRunUninstall_ReturnsFalseOnFailure()
    _TestFmkHeader("Test: __RunUninstall() - returns False when a step fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor\TestFramework"
    $g_sInstallPath = "C:\AutoIt3\TestFramework"

    _SetStubReturn("FileDelete", $_1st, 0)  ; first file delete fails - throws RemoveFileException

    Local $bResult = __RunUninstall(10, 11)
	Local $sStackMsg = _GetStubCall("MsgBox", $_1st, $Param_Text)
	Local $bPrintException = StringInStr($sStackMsg, "RemoveFileException") ? True : False

    _TestFmkAssert($bResult = False, 		"Returns False on failure", 				 $bResult, 		   False, $TST_WIZ_UNINSTALLER_TESTS)
	_TestFmkAssert($bPrintException = True, "Display a message with expected exception", $bPrintException, True,  $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - _UninstallUpdateReadyPage
;================================================================================================================================

Func _TestUpdateReadyPage_ContainsPaths()
    _TestFmkHeader("Test: _UninstallUpdateReadyPage() - returned text contains include and install paths")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\TestFramework"

    Local $sResult = _UninstallUpdateReadyPage()

    Local $bHasIncludePath = StringInStr($sResult, $g_sIncludePath) > 0
    Local $bHasInstallPath = StringInStr($sResult, $g_sInstallPath) > 0
    _TestFmkAssert($bHasIncludePath, "Text contains include path", $bHasIncludePath, True, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($bHasInstallPath, "Text contains install path", $bHasInstallPath, True, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __Uninstall
;================================================================================================================================

Func _TestUninstall_BuildsWizardCorrectly()
    _TestFmkHeader("Test: __Uninstall() - builds wizard with correct pages and IDs")

    For $i = 1 To 17
        _SetStubReturn("IsHWnd", $i, True)
    Next
    _SetStubReturn("GUICtrlCreateButton", $_1st, 10)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, 11)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, 12)

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\TestFramework"

    Local $mWizard = __Uninstall()

    _TestFmkAssert(__MaxPages($mWizard.mPages) = 4, "Wizard has 4 pages",    __MaxPages($mWizard.mPages), 4, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($mWizard.iIntroPageId    = 1,    "Intro page ID is 1",    $mWizard.iIntroPageId,       1, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($mWizard.iReadyPageId    = 2,    "Ready page ID is 2",    $mWizard.iReadyPageId,       2, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($mWizard.iProgressPageId = 3,    "Progress page ID is 3", $mWizard.iProgressPageId,    3, $TST_WIZ_UNINSTALLER_TESTS)
    _TestFmkAssert($mWizard.iFinishPageId   = 4,    "Finish page ID is 4",   $mWizard.iFinishPageId,      4, $TST_WIZ_UNINSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Run tests
;================================================================================================================================

Func __RunCrucialWizUninstallerTest_ReadInstallRecord(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestReadInstallRecord_Success,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestReadInstallRecord_IncludePathMissing, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestReadInstallRecord_InstallPathMissing, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_IsRunningFromInstallFolder(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestIsRunningFromInstallFolder_True,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestIsRunningFromInstallFolder_False, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_RelaunchFromTemp(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRelaunchFromTemp_CopiesAndLaunches, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_RemoveIncludeRegistry(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_RemovesOnlyTFWPath,        $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_DeletesKeyWhenOnlyTFWPath, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_DoesNothingWhenMissing,    $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_ErrorOnRegDeleteFailure,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_ErrorOnRegWriteFailure,   $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_ThrowsOnRegDeleteFailure,  $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveIncludeRegistry_ThrowsOnRegWriteFailure,   $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_RemoveFolderIfEmpty(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRemoveFolderIfEmpty_RemovesWhenEmpty,             $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveFolderIfEmpty_DoesNotRemoveWhenNotEmpty,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveFolderIfEmpty_DoesNothingWhenFolderMissing, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveFolderIfEmpty_ErrorOnDirRemoveFailure, 	 $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveFolderIfEmpty_ThrowsOnDirRemoveFailure, 	 $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_RemoveInstalledFile(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRemoveInstalledFile_ReturnsTrueOnSuccess,   $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveInstalledFile_SetErrorOnFailure,      $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveInstalledFile_ThrowsOnFailure,        $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRemoveInstalledFile_CallsFileDelete,        $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestRemoveInstalledFile_SkipsWhenFileNotExists, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_RunUninstall(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunUninstall_ReturnsTrueOnSuccess,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunUninstall_ReturnsFalseOnFailure, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_UninstallUpdateReadyPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestUpdateReadyPage_ContainsPaths, $bAllPassed)
EndFunc

Func __RunCrucialWizUninstallerTest_Uninstall(ByRef $bAllPassed)
    _TestFmkSeparator()
	$bAllPassed = _TestFmkRun(_TestUninstall_BuildsWizardCorrectly, $bAllPassed)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; [MAIN] Run Test Suite
;================================================================================================================================

Func _RunCrucialWizUninstallerTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialWizUninstallerTest_ReadInstallRecord($bAllPassed)
    __RunCrucialWizUninstallerTest_IsRunningFromInstallFolder($bAllPassed)
    __RunCrucialWizUninstallerTest_RelaunchFromTemp($bAllPassed)
    __RunCrucialWizUninstallerTest_RemoveIncludeRegistry($bAllPassed)
    __RunCrucialWizUninstallerTest_RemoveFolderIfEmpty($bAllPassed)
	__RunCrucialWizUninstallerTest_RemoveInstalledFile($bAllPassed)
    __RunCrucialWizUninstallerTest_RunUninstall($bAllPassed)
    __RunCrucialWizUninstallerTest_UninstallUpdateReadyPage($bAllPassed)
    __RunCrucialWizUninstallerTest_Uninstall($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc

; Entry point
_TestFmkRunAllTests(_RunCrucialWizUninstallerTests, $TST_WIZ_UNINSTALLER_TESTS)

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================
