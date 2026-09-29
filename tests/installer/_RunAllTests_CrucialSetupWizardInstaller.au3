#include "CrucialSetupWizardInstallerTests.au3"
#include "CrucialSetupWizardUninstallerTests.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - _RunAllTests_CrucialSetupWizardInstaller.au3
; Version .......: 1.0.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Runs all Crucial Setup Wizard installer and uninstaller test suites.
; ===============================================================================================================================
_TestFmk_SetSilentMode(True)

Func _RunAllTests_CrucialSetupWizardInstaller()

	Local $bWriteSummary = False
	Local $bAllPassed = True

	$bAllPassed = _RunCrucialSetupWizardInstallerTests($bWriteSummary) And $bAllPassed
	$bAllPassed = _RunCrucialSetupWizardUninstallerTests($bWriteSummary) And $bAllPassed

	_TestFmkSeparator(80, "=")
	__TestFmk_InfoConsoleWrite("+ Summary")
	_TestFmkSummary()

	Return $bAllPassed
EndFunc
Exit Not _RunAllTests_CrucialSetupWizardInstaller()