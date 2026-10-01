#include "CrucialWizInstallerTests.au3"
#include "CrucialWizUninstallerTests.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - _RunAllTests_CrucialWizInstaller.au3
; Version .......: 1.1.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Runs all Crucial Setup Wizard installer and uninstaller test suites.
; ===============================================================================================================================
_TestFmk_SetSilentMode(True)

Func _RunAllTests_CrucialWizInstaller()

	Local $bWriteSummary = False
	Local $bAllPassed = True

	$bAllPassed = _RunCrucialWizInstallerTests($bWriteSummary) And $bAllPassed
	$bAllPassed = _RunCrucialWizUninstallerTests($bWriteSummary) And $bAllPassed

	_TestFmkSeparator(80, "=")
	__TestFmk_InfoConsoleWrite("+ Summary")
	_TestFmkSummary()

	Return $bAllPassed
EndFunc
Exit Not _RunAllTests_CrucialWizInstaller()