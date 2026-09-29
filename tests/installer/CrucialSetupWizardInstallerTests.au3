#include <TestFramework.au3>
#include <StubConstants.au3>
#include "..\..\src\installer\CrucialSetupWizardInstaller.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialSetupWizardInstallerTests.au3
; Version .......: 1.0.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Unit tests for CrucialSetupWizardInstaller.au3.
;                  Tests path detection, existing install detection, registry writers,
;                  install logic, and wizard setup.
; ===============================================================================================================================
Local Const $TST_WIZ_INSTALLER_TESTS = "CrucialSetupWizardInstallerTests.au3"

;================================================================================================================================
#Region ; Tests - __DetectPaths
;================================================================================================================================

Func _TestDetectPaths_FromWowKey()
    _TestFmkHeader("Test: __DetectPaths() - reads AutoIt dir from WOW registry key")

	Local $sWoWAutoItDir = "C:\Program Files (x86)\AutoIt3"
	Local $sDerivedIncludePath = $sWoWAutoItDir & "\Include\Vendor"
	Local $sDerivedInstallPath = $sWoWAutoItDir & "\CrucialSetupWizard"
	_SetStubReturn("RegRead", $_1st, $sWoWAutoItDir)

    __DetectPaths()

    _TestFmkAssert($g_sAutoItDir   = $sWoWAutoItDir,   "AutoItDir set from WOW key", $g_sAutoItDir,   $sWoWAutoItDir, 		$TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($g_sIncludePath = $sDerivedIncludePath, "IncludePath derived",  	 $g_sIncludePath, $sDerivedIncludePath, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($g_sInstallPath = $sDerivedInstallPath, "InstallPath derived",    $g_sInstallPath, $sDerivedInstallPath, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestDetectPaths_FallsBackToRegularKey()
    _TestFmkHeader("Test: __DetectPaths() - falls back to regular registry key when WOW key fails")

    Local $sRegAutoItDir = "C:\Program Files\AutoIt3"
	_SetStubReturn("RegRead", $_1st, $STUB_ERROR)
    _SetStubReturn("RegRead", $_2nd, $sRegAutoItDir)

    __DetectPaths()

    _TestFmkAssert($g_sAutoItDir = $sRegAutoItDir, "AutoItDir set from regular key", $g_sAutoItDir, $sRegAutoItDir, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestDetectPaths_FallsBackToDefault()
    _TestFmkHeader("Test: __DetectPaths() - falls back to default path when both registry reads fail")

    Local $sDefaultAutoItDir = "C:\Program Files (x86)\AutoIt3"
	_SetStubReturn("RegRead", $_1st, $STUB_ERROR)
    _SetStubReturn("RegRead", $_2nd, $STUB_ERROR)

    __DetectPaths()

    _TestFmkAssert($g_sAutoItDir = $sDefaultAutoItDir, "AutoItDir set to default", $g_sAutoItDir, $sDefaultAutoItDir, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __CheckExistingInstall
;================================================================================================================================

Func _TestCheckExistingInstall_NoExistingInstall()
    _TestFmkHeader("Test: __CheckExistingInstall() - sets bIsUpgrade False when no existing version")

    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)

    __CheckExistingInstall()

    _TestFmkAssert($g_bIsUpgrade = False, "bIsUpgrade is False", $g_bIsUpgrade, False, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestCheckExistingInstall_ExistingInstallFound()
    _TestFmkHeader("Test: __CheckExistingInstall() - sets bIsUpgrade True when existing version found")

    _SetStubReturn("RegRead", $_1st, "0.0.1")

    __CheckExistingInstall()

    _TestFmkAssert($g_bIsUpgrade = True, "bIsUpgrade is True", $g_bIsUpgrade, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestCheckExistingInstall_UpdatesIncludePathWhenExists()
    _TestFmkHeader("Test: __CheckExistingInstall() - updates IncludePath from registry when path exists on disk")

    _SetStubReturn("RegRead",     $_1st, "0.0.1")
    _SetStubReturn("RegRead",     $_2nd, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("FileExists",  $_1st, True)

    __CheckExistingInstall()

    _TestFmkAssert($g_sIncludePath = "C:\AutoIt3\Include\Vendor", "IncludePath updated", $g_sIncludePath, "C:\AutoIt3\Include\Vendor", $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestCheckExistingInstall_KeepsDetectedIncludePathWhenNotExists()
    _TestFmkHeader("Test: __CheckExistingInstall() - keeps detected IncludePath when registry path does not exist on disk")

    $g_sIncludePath = "C:\Detected\Include"
    _SetStubReturn("RegRead",    $_1st, "0.0.1")
    _SetStubReturn("RegRead",    $_2nd, "C:\AutoIt3\Include\Vendor")
    _SetStubReturn("FileExists", $_1st, False)

    __CheckExistingInstall()

    _TestFmkAssert($g_sIncludePath = "C:\Detected\Include", "IncludePath unchanged", $g_sIncludePath, "C:\Detected\Include", $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestCheckExistingInstall_UpdatesInstallPathWhenExists()
    _TestFmkHeader("Test: __CheckExistingInstall() - updates InstallPath from registry when path exists on disk")

    _SetStubReturn("RegRead",    $_1st, "0.0.1")
    _SetStubReturn("RegRead",    $_2nd, $STUB_ERROR)
    _SetStubReturn("RegRead",    $_3rd, "C:\AutoIt3\CrucialSetupWizard")
    _SetStubReturn("FileExists", $_1st, True)

    __CheckExistingInstall()

    _TestFmkAssert($g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard", "InstallPath updated", $g_sInstallPath, "C:\AutoIt3\CrucialSetupWizard", $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestCheckExistingInstall_KeepsDetectedInstallPathWhenNotExists()
    _TestFmkHeader("Test: __CheckExistingInstall() - keeps detected InstallPath when registry path does not exist on disk")

    $g_sInstallPath = "C:\Detected\CrucialSetupWizard"
    _SetStubReturn("RegRead",    $_1st, "0.0.1")
    _SetStubReturn("RegRead",    $_2nd, $STUB_ERROR)
    _SetStubReturn("RegRead",    $_3rd, "C:\AutoIt3\CrucialSetupWizard")
    _SetStubReturn("FileExists", $_1st, False)

    __CheckExistingInstall()

    _TestFmkAssert($g_sInstallPath = "C:\Detected\CrucialSetupWizard", "InstallPath unchanged", $g_sInstallPath, "C:\Detected\CrucialSetupWizard", $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __WriteIncludeRegistry
;================================================================================================================================

Func _TestWriteIncludeRegistry_WritesWhenEmpty()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - writes path when registry entry is empty")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)

	_Try()
		__WriteIncludeRegistry()
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
	_EndTry()

    Local $sWritten = _GetStubCall("RegWrite", $_1st, $Param_Value)

    _TestFmkAssert($sWritten = $g_sIncludePath, "Path written to registry", $sWritten, 		   $g_sIncludePath, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False,   "No exception thrown", 		$bExceptionThrown, False, 			$TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteIncludeRegistry_AppendsWhenOtherPathsExist()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - appends path when other paths exist in registry")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead", $_1st, "C:\OtherPath")

	_Try()
		__WriteIncludeRegistry()
        Local $e
        Local $bExceptionThrown = _Catch($e) ? True : False
	_EndTry()

    Local $sWritten = _GetStubCall("RegWrite", $_1st, $Param_Value)

    _TestFmkAssert($sWritten = "C:\OtherPath;" & $g_sIncludePath, "Path appended to registry", $sWritten, "C:\OtherPath;" & $g_sIncludePath, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False, "No exception thrown", $bExceptionThrown, False, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteIncludeRegistry_DoesNotWriteWhenAlreadyPresent()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - does not write when path already present")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead", $_1st, "C:\AutoIt3\Include\Vendor")

	__WriteIncludeRegistry()

    _TestFmkAssert(_StubCallCount("RegWrite") = 0, "RegWrite not called", _StubCallCount("RegWrite"), 0, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteIncludeRegistry_ErrorOnRegWriteFailure()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - sets @error when RegWrite() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)
	_SetStubReturn("RegWrite", $_1st, $STUB_ERROR)

	__WriteIncludeRegistry()
	Local $iErr = @error

	_TestFmkAssert(_StubCallCount("RegWrite") = 1, "RegWrite called", 				  _StubCallCount("RegWrite"), 1,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,        		       "Sets @error on RegWrite failure", $iErr > 0, 		          True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteIncludeRegistry_ThrowsOnRegWriteFailure()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - thrown expected exception when RegWrite() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    _SetStubReturn("RegRead", $_1st, $STUB_ERROR)
	_SetStubReturn("RegWrite", $_1st, $STUB_ERROR)

	_Try()
		__WriteIncludeRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("WriteIncludeRegistry")) ? True : False
	_EndTry()

	_TestFmkAssert(_StubCallCount("RegWrite") = 1, "RegWrite called", 				  	   _StubCallCount("RegWrite"), 1,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = True,       """WriteIncludeRegistry"" type thrown", $bExceptionThrown, 		   True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __WriteInstallRegistry
;================================================================================================================================

Func _TestWriteInstallRegistry_WritesAllKeys()
    _TestFmkHeader("Test: __WriteInstallRegistry() - writes version, include path and install path")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	_Try()
		__WriteInstallRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e) ? True : False
	_EndTry()

    Local $sVersion     = _GetStubCall("RegWrite", $_1st, $Param_Value)
    Local $sIncludePath = _GetStubCall("RegWrite", $_2nd, $Param_Value)
    Local $sInstallPath = _GetStubCall("RegWrite", $_3rd, $Param_Value)
    _TestFmkAssert($sVersion     = $WIZ_INSTALLER_VERSION, "Version written",       $sVersion,     	   $WIZ_INSTALLER_VERSION, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sIncludePath = $g_sIncludePath,        "IncludePath written",   $sIncludePath, 	   $g_sIncludePath, 	   $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sInstallPath = $g_sInstallPath,        "InstallPath written",   $sInstallPath, 	   $g_sInstallPath, 	   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False,   		   "No exception thrown", 	$bExceptionThrown, False, 				   $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteInstallRegistry_ErrorOnRegWriteFailForVersion()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - sets @error when RegWrite() for Version fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_ERROR)	; Version
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; IncludePath
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; InstallPath

	__WriteInstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 1, "RegWrite called 1x", 				  $iRegWrite, 1,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 1st RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteInstallRegistry_ErrorOnRegWriteFailForInclude()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - sets @error when RegWrite() for IncludePath fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; Version
	_SetStubReturn("RegWrite", $_2nd, $STUB_ERROR)	; IncludePath
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; InstallPath

	__WriteInstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 2, "RegWrite called 2x", 				  $iRegWrite, 2,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 2nd RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteInstallRegistry_ErrorOnRegWriteFailForInstall()
    _TestFmkHeader("Test: __WriteIncludeRegistry() - sets @error when RegWrite() for InstallPath fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; Version
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; IncludePath
	_SetStubReturn("RegWrite", $_3rd, $STUB_ERROR)	; InstallPath

	__WriteInstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 3, "RegWrite called 3x", 				  $iRegWrite, 3,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 3rd RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteInstallRegistry_ThrowsOnRegWriteFailure()
    _TestFmkHeader("Test: __WriteInstallRegistry() - thrown expected exception when any RegWrite() fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; Version
	_SetStubReturn("RegWrite", $_2nd, $STUB_ERROR)	; IncludePath
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; InstallPath

	_Try()
		__WriteInstallRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("WriteInstallRegistry")) ? True : False
	_EndTry()
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite > 0, 			 "RegWrite called", 				  	   $iRegWrite > 0, 	  True, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = True, """WriteInstallRegistry"" type thrown",   $bExceptionThrown, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __WriteUninstallRegistry
;================================================================================================================================

Func _TestWriteUninstallRegistry_WritesAllKeys()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - writes all required uninstall registry values correctly")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"
    Local $sExpectedUninstallString = '"' & $g_sInstallPath & '\CrucialSetupWizardUninstaller.exe"'

	_Try()
		__WriteUninstallRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e) ? True : False
	_EndTry()

    Local $sDisplayName    = _GetStubCall("RegWrite", $_1st, $Param_Value)
    Local $sDisplayVersion = _GetStubCall("RegWrite", $_2nd, $Param_Value)
    Local $sPublisher      = _GetStubCall("RegWrite", $_3rd, $Param_Value)
    Local $sUninstallStr   = _GetStubCall("RegWrite", $_4th, $Param_Value)
    Local $iNoModify       = _GetStubCall("RegWrite", $_5th, $Param_Value)

    _TestFmkAssert(_StubCallCount("RegWrite") = 5, 				  "Five registry values written", _StubCallCount("RegWrite"),  5, 		   $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sDisplayName     = "Crucial Setup Wizard",    "DisplayName written",     $sDisplayName,     "Crucial Setup Wizard",   $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sDisplayVersion  = $WIZ_INSTALLER_VERSION,    "DisplayVersion written",  $sDisplayVersion,  $WIZ_INSTALLER_VERSION,    $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sPublisher       = "Crucial Thread",          "Publisher written",       $sPublisher,       "Crucial Thread", 	       $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sUninstallStr    = $sExpectedUninstallString, "UninstallString written", $sUninstallStr,    $sExpectedUninstallString, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($iNoModify        = 1,                         "NoModify written",        $iNoModify,        1, 						   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = False,   		   		  "No exception thrown", 	 $bExceptionThrown, False, 				       $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ErrorOnRegWriteFailForDisplayName()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - sets @error when RegWrite() for DisplayName fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_ERROR)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_SUCESS)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_SUCESS)	; NoModify

	__WriteUninstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 1, "RegWrite called 1x", 				  $iRegWrite, 1,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 1st RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ErrorOnRegWriteFailForDisplayVersion()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - sets @error when RegWrite() for DisplayVersion fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_ERROR)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_SUCESS)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_SUCESS)	; NoModify

	__WriteUninstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 2, "RegWrite called 2x", 				  $iRegWrite, 2,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 2nd RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ErrorOnRegWriteFailForPublisher()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - sets @error when RegWrite() for Publisher fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_ERROR)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_SUCESS)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_SUCESS)	; NoModify

	__WriteUninstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 3, "RegWrite called 3x", 				  $iRegWrite, 3,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 3rd RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ErrorOnRegWriteFailForUninstall()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - sets @error when RegWrite() for UninstallString fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_ERROR)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_SUCESS)	; NoModify

	__WriteUninstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 4, "RegWrite called 4x", 				  $iRegWrite, 4,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 4th RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ErrorOnRegWriteFailForNoModify()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - sets @error when RegWrite() for NoModify fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_SUCESS)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_SUCESS)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_ERROR)	; NoModify

	__WriteUninstallRegistry()
	Local $iErr = @error
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite = 5, "RegWrite called 5x", 				  $iRegWrite, 5,    $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iErr > 0,      "Sets @error on 5th RegWrite failure", $iErr > 0,  True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestWriteUninstallRegistry_ThrowsOnRegWriteFailure()
    _TestFmkHeader("Test: __WriteUninstallRegistry() - thrown expected exception when any RegWrite() fails")

    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

	Local Const $STUB_SUCESS = 1
	_SetStubReturn("RegWrite", $_1st, $STUB_SUCESS)	; DisplayName
	_SetStubReturn("RegWrite", $_2nd, $STUB_SUCESS)	; DisplayVersion
	_SetStubReturn("RegWrite", $_3rd, $STUB_ERROR)	; Publisher
	_SetStubReturn("RegWrite", $_4th, $STUB_SUCESS)	; UninstallString
	_SetStubReturn("RegWrite", $_5th, $STUB_SUCESS)	; NoModify

	_Try()
		__WriteUninstallRegistry()
		Local $e
		Local $bExceptionThrown = _Catch($e, _AsExceptionType("WriteUninstallRegistry")) ? True : False
	_EndTry()
	Local $iRegWrite = _StubCallCount("RegWrite")

	_TestFmkAssert($iRegWrite > 0, 			 "RegWrite called", 				  	   $iRegWrite > 0, 	  True, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bExceptionThrown = True, """WriteUninstallRegistry"" type thrown", $bExceptionThrown, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __InstallFile
;================================================================================================================================

Func _TestInstallFile_ReturnsTrueOnSuccess()
    _TestFmkHeader("Test: __InstallFile() - returns True when file included successfully")

	$g_sIncludePath = "C:\AutoIt3\Include\Vendor"
	Local $sFilePath = "..\core\CrucialSetupWizard.au3"

	_Tstbl_Implement_FileInstall(__FileInstall)
    _SetStubReturn("FileInstall", $_1st, 1)

    Local $bResult = __InstallFile("..\core\CrucialSetupWizard.au3", $g_sIncludePath & "\CrucialSetupWizard.au3", $FC_OVERWRITE)
    Local $sFileInstall = _GetStubCall("FileInstall", $_1st, $Param_Source)

    _TestFmkAssert($bResult = True, "Returns True on success", $bResult, True, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($sFileInstall = $sFilePath, "FileInstall called with correct path", $sFileInstall, $sFilePath, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestInstallFile_SetErrorOnFailure()
    _TestFmkHeader("Test: __InstallFile() - sets @error and returns False when FileInstall() fails")

	$g_sIncludePath = "C:\AutoIt3\Include\Vendor"
	_Tstbl_Implement_FileInstall(__FileInstall)
    _SetStubReturn("FileInstall", $_1st, 0)

	Local $bResult = __InstallFile("..\core\CrucialSetupWizard.au3", $g_sIncludePath & "\CrucialSetupWizard.au3", $FC_OVERWRITE)
	Local $iErr    = @error

    _TestFmkAssert($bResult = False, "Returns False on failure", $bResult, False, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($iErr > 0,        "Sets @error on failure",   $iErr > 0, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestInstallFile_ThrowsOnFailure()
    _TestFmkHeader("Test: __InstallFile() - thrown expected exception when FileInstall() fails")

	$g_sIncludePath = "C:\AutoIt3\Include\Vendor"
	_Tstbl_Implement_FileInstall(__FileInstall)
    _SetStubReturn("FileInstall", $_1st, 0)

    _Try()
		__InstallFile("..\core\CrucialSetupWizard.au3", $g_sIncludePath & "\CrucialSetupWizard.au3", $FC_OVERWRITE)
        Local $e
        Local $bExceptionThrown = _Catch($e, _AsExceptionType("FileInstallException")) ? True : False
    _EndTry()

	_TestFmkAssert($bExceptionThrown = True, """FileInstallException"" type thrown", $bExceptionThrown, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __RunInstall
;================================================================================================================================

Func _TestRunInstall_ReturnsTrueOnSuccess()
    _TestFmkHeader("Test: __RunInstall() - returns True when all steps succeed")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

    Local $bResult = __RunInstall(10, 11)

	Local $sDirInclude 		= _GetStubCall("DirCreate", $_1st, $Param_Path)
	Local $sDirInstall 		= _GetStubCall("DirCreate", $_2nd, $Param_Path)
	Local $sIncludeRegKey 	= _GetStubCall("RegWrite", $_1st, $Param_Keyname)	; (1/9) __WriteIncludeRegistry 	 (1 RegWrite)
	Local $sInstallRegKey 	= _GetStubCall("RegWrite", $_2nd, $Param_Keyname)	; (2/9) __WriteInstallRegistry 	 (3 RegWrites)
	Local $sUninstallRegKey = _GetStubCall("RegWrite", $_5th, $Param_Keyname)	; (5/9) __WriteUninstallRegistry (5 RegWrites)
	Local $iProgessCount	= _StubCallCount("GUICtrlSetData")
	Local $iFilesInstalled  = _StubCallCount("FileInstall")

    _TestFmkAssert($bResult = True, 					   "Returns True on success", 		   $bResult, 		  True, 			   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($sDirInclude = $g_sIncludePath, 		   "Include folder created", 		   $sDirInclude, 	  $g_sIncludePath, 	   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($sDirInstall = $g_sInstallPath, 		   "Install folder created", 		   $sDirInstall, 	  $g_sInstallPath, 	   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($iFilesInstalled = 4,     			   "All 4 files included",             $iFilesInstalled,  4, 				   $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($sIncludeRegKey  = $REG_AUTOIT_INCLUDE, "Include registry key created",     $sIncludeRegKey,	  $REG_AUTOIT_INCLUDE, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($sInstallRegKey  = $REG_INSTALL_KEY,    "Install registry key created",     $sInstallRegKey,   $REG_INSTALL_KEY,    $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($sUninstallRegKey = $REG_UNINSTALL_KEY, "Uninstall registry key created",   $sUninstallRegKey, $REG_UNINSTALL_KEY,  $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($iProgessCount = 14, 				   "Progress updated for all steps",   $iProgessCount, 	  14, 				   $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestRunInstall_ReturnsFalseOnFailure()
    _TestFmkHeader("Test: __RunInstall() - returns False when a step fails")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"
    _SetStubReturn("FileInstall", $_1st, 0)

    Local $bResult = __RunInstall(10, 11)
	Local $sConsoleWriteReturn = _GetStubCall("ConsoleWrite", $_1st, $Param_Text)
	Local $bPrintException = StringInStr($sConsoleWriteReturn, "FileInstallException") ? True : False

    _TestFmkAssert($bResult = False, 		"Returns False on failure", 					   $bResult, 		 False, $TST_WIZ_INSTALLER_TESTS)
	_TestFmkAssert($bPrintException = True, "Write expected exception stack entry on console", $bPrintException, True,  $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - _UpdateIncludePath
;================================================================================================================================

Func _TestUpdateIncludePath_UpdatesGlobal()
    _TestFmkHeader("Test: _UpdateIncludePath() - updates g_sIncludePath from input control")

    _SetStubReturn("GUICtrlRead", $_1st, "C:\NewPath\Include")

    _UpdateIncludePath(10)

    _TestFmkAssert($g_sIncludePath = "C:\NewPath\Include", "IncludePath updated", $g_sIncludePath, "C:\NewPath\Include", $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - _UpdateReadyPage
;================================================================================================================================

Func _TestUpdateReadyPage_ContainsIncludePath()
    _TestFmkHeader("Test: _UpdateReadyPage() - returned text contains include path")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

    Local $sResult = _UpdateReadyPage()

    _TestFmkAssert(StringInStr($sResult, $g_sIncludePath) > 0, "Text contains include path", StringInStr($sResult, $g_sIncludePath) > 0, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestUpdateReadyPage_ContainsInstallPath()
    _TestFmkHeader("Test: _UpdateReadyPage() - returned text contains install path")

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

    Local $sResult = _UpdateReadyPage()

    _TestFmkAssert(StringInStr($sResult, $g_sInstallPath) > 0, "Text contains install path", StringInStr($sResult, $g_sInstallPath) > 0, True, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Tests - __Installation
;================================================================================================================================

Func _TestInstallation_BuildsWizardWithCorrectPageCount()
    _TestFmkHeader("Test: __Installation() - builds wizard with 5 pages")

    For $i = 1 To 17
        _SetStubReturn("IsHWnd", $i, True)
    Next
    _SetStubReturn("GUICtrlCreateButton", $_1st, 10)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, 11)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, 12)

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

    Local $mWizard = __Installation()

    _TestFmkAssert(__MaxPages($mWizard.mPages) = 5, "Wizard has 5 pages", __MaxPages($mWizard.mPages), 5, $TST_WIZ_INSTALLER_TESTS)
EndFunc

Func _TestInstallation_StoresPageIds()
    _TestFmkHeader("Test: __Installation() - stores correct page IDs in wizard map")

    For $i = 1 To 17
        _SetStubReturn("IsHWnd", $i, True)
    Next
    _SetStubReturn("GUICtrlCreateButton", $_1st, 10)
    _SetStubReturn("GUICtrlCreateButton", $_2nd, 11)
    _SetStubReturn("GUICtrlCreateButton", $_3rd, 12)

    $g_sIncludePath = "C:\AutoIt3\Include\Vendor"
    $g_sInstallPath = "C:\AutoIt3\CrucialSetupWizard"

    Local $mWizard = __Installation()

    _TestFmkAssert($mWizard.iIntroPageId    = 1, "Intro page ID is 1",    $mWizard.iIntroPageId,    1, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($mWizard.iPathPageId     = 2, "Path page ID is 2",     $mWizard.iPathPageId,     2, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($mWizard.iReadyPageId    = 3, "Ready page ID is 3",    $mWizard.iReadyPageId,    3, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($mWizard.iProgressPageId = 4, "Progress page ID is 4", $mWizard.iProgressPageId, 4, $TST_WIZ_INSTALLER_TESTS)
    _TestFmkAssert($mWizard.iFinishPageId   = 5, "Finish page ID is 5",   $mWizard.iFinishPageId,   5, $TST_WIZ_INSTALLER_TESTS)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Run tests
;================================================================================================================================

Func __RunCrucialSetupWizardInstallerTest_DetectPaths(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestDetectPaths_FromWowKey,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestDetectPaths_FallsBackToRegularKey,   $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestDetectPaths_FallsBackToDefault,      $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_CheckExistingInstall(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_NoExistingInstall,               $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_ExistingInstallFound,            $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_UpdatesIncludePathWhenExists,    $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_KeepsDetectedIncludePathWhenNotExists, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_UpdatesInstallPathWhenExists,              $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestCheckExistingInstall_KeepsDetectedInstallPathWhenNotExists,     $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_WriteIncludeRegistry(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestWriteIncludeRegistry_WritesWhenEmpty,           		$bAllPassed)
    $bAllPassed = _TestFmkRun(_TestWriteIncludeRegistry_AppendsWhenOtherPathsExist,		$bAllPassed)
    $bAllPassed = _TestFmkRun(_TestWriteIncludeRegistry_DoesNotWriteWhenAlreadyPresent, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteIncludeRegistry_ErrorOnRegWriteFailure, 		$bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteIncludeRegistry_ThrowsOnRegWriteFailure, 		$bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_WriteInstallRegistry(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestWriteInstallRegistry_WritesAllKeys, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteInstallRegistry_ErrorOnRegWriteFailForVersion, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteInstallRegistry_ErrorOnRegWriteFailForInclude, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteInstallRegistry_ErrorOnRegWriteFailForInstall, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteInstallRegistry_ThrowsOnRegWriteFailure, $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_WriteUninstallRegistry(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_WritesAllKeys, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ErrorOnRegWriteFailForDisplayName, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ErrorOnRegWriteFailForDisplayVersion, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ErrorOnRegWriteFailForPublisher, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ErrorOnRegWriteFailForUninstall, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ErrorOnRegWriteFailForNoModify, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestWriteUninstallRegistry_ThrowsOnRegWriteFailure, $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_InstallFile(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestInstallFile_ReturnsTrueOnSuccess, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestInstallFile_SetErrorOnFailure, $bAllPassed)
	$bAllPassed = _TestFmkRun(_TestInstallFile_ThrowsOnFailure, $bAllPassed)

EndFunc

Func __RunCrucialSetupWizardInstallerTest_RunInstall(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestRunInstall_ReturnsTrueOnSuccess,  $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestRunInstall_ReturnsFalseOnFailure, $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_UpdateIncludePath(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestUpdateIncludePath_UpdatesGlobal, $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_UpdateReadyPage(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestUpdateReadyPage_ContainsIncludePath, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestUpdateReadyPage_ContainsInstallPath, $bAllPassed)
EndFunc

Func __RunCrucialSetupWizardInstallerTest_Installation(ByRef $bAllPassed)
    _TestFmkSeparator()
    $bAllPassed = _TestFmkRun(_TestInstallation_BuildsWizardWithCorrectPageCount, $bAllPassed)
    $bAllPassed = _TestFmkRun(_TestInstallation_StoresPageIds,                    $bAllPassed)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; [MAIN] Run Test Suite
;================================================================================================================================

Func _RunCrucialSetupWizardInstallerTests($bWriteSummary = True)
    Local $bAllPassed = True
    __RunCrucialSetupWizardInstallerTest_DetectPaths($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_CheckExistingInstall($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_WriteIncludeRegistry($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_WriteInstallRegistry($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_WriteUninstallRegistry($bAllPassed)
	__RunCrucialSetupWizardInstallerTest_InstallFile($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_RunInstall($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_UpdateIncludePath($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_UpdateReadyPage($bAllPassed)
    __RunCrucialSetupWizardInstallerTest_Installation($bAllPassed)
    If $bWriteSummary Then _TestFmkSummary()
    Return $bAllPassed
EndFunc

; Entry point
_TestFmkRunAllTests(_RunCrucialSetupWizardInstallerTests, $TST_WIZ_INSTALLER_TESTS)

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================
