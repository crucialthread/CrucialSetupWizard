#include "CrucialSetupWizardErrorTests.au3"
#include "CrucialSetupWizardConfigTests.au3"
#include "CrucialSetupWizardEventsTests.au3"
#include "CrucialSetupWizardPageHelpersTests.au3"
#include "CrucialSetupWizardPageCtrlTests.au3"
#include "CrucialSetupWizardButtonsTests.au3"
#include "CrucialSetupWizardPageOpsTests.au3"
#include "CrucialSetupWizardNavTests.au3"
#include "CrucialSetupWizardPageTemplateEventsTests.au3"
#include "CrucialSetupWizardPageTemplatesTests.au3"
#include "CrucialSetupWizardHeaderTests.au3"
#include "CrucialSetupWizardMainTests.au3"
#include "CrucialSetupWizardInitTests.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - _RunAllTests_CrucialSetupWizard.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Runner script that executes all Crucial Installer test suites.
; ===============================================================================================================================
_TestFmk_SetSilentMode(True)

Func _RunAllTests_CrucialSetupWizard()

	Local $bWriteSummary = False

	_RunCrucialSetupWizardErrorTests($bWriteSummary)
	_RunCrucialSetupWizardConfigTests($bWriteSummary)
	_RunCrucialSetupWizardEventsTests($bWriteSummary)
	_RunCrucialSetupWizardPageHelpersTests($bWriteSummary)
	_RunCrucialSetupWizardPageCtrlTests($bWriteSummary)
	_RunCrucialSetupWizardButtonsTests($bWriteSummary)
	_RunCrucialSetupWizardPageOpsTests($bWriteSummary)
	_RunCrucialSetupWizardNavTests($bWriteSummary)
	_RunCrucialSetupWizardPageTemplateEventsTests($bWriteSummary)
	_RunCrucialSetupWizardPageTemplatesTests($bWriteSummary)
	_RunCrucialSetupWizardHeaderTests($bWriteSummary)
	_RunCrucialSetupWizardMainTests($bWriteSummary)
	_RunCrucialSetupWizardInitTests($bWriteSummary)

	_TestFmkSeparator(80, "=")
	ConsoleWrite("+ Summary")
	_TestFmkSummary()
EndFunc
_RunAllTests_CrucialSetupWizard()