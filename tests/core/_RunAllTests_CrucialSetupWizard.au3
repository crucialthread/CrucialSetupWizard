#include "CrucialWizErrorTests.au3"
#include "CrucialWizConfigTests.au3"
#include "CrucialWizEventsTests.au3"
#include "CrucialWizPageHelpersTests.au3"
#include "CrucialWizPageCtrlTests.au3"
#include "CrucialWizButtonsTests.au3"
#include "CrucialWizPageOpsTests.au3"
#include "CrucialWizNavTests.au3"
#include "CrucialWizPageTemplateEventsTests.au3"
#include "CrucialWizPageTemplatesTests.au3"
#include "CrucialWizHeaderTests.au3"
#include "CrucialWizMainTests.au3"
#include "CrucialWizInitTests.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - _RunAllTests_CrucialSetupWizard.au3
; Version .......: 1.2.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Runner script that executes all Crucial Installer test suites.
; ===============================================================================================================================
_TestFmk_SetSilentMode(True)

Func _RunAllTests_CrucialSetupWizard()

	Local $bWriteSummary = False

	_RunCrucialWizErrorTests($bWriteSummary)
	_RunCrucialWizConfigTests($bWriteSummary)
	_RunCrucialWizEventsTests($bWriteSummary)
	_RunCrucialWizPageHelpersTests($bWriteSummary)
	_RunCrucialWizPageCtrlTests($bWriteSummary)
	_RunCrucialWizButtonsTests($bWriteSummary)
	_RunCrucialWizPageOpsTests($bWriteSummary)
	_RunCrucialWizNavTests($bWriteSummary)
	_RunCrucialWizPageTemplateEventsTests($bWriteSummary)
	_RunCrucialWizPageTemplatesTests($bWriteSummary)
	_RunCrucialWizHeaderTests($bWriteSummary)
	_RunCrucialWizMainTests($bWriteSummary)
	_RunCrucialWizInitTests($bWriteSummary)

	_TestFmkSeparator(80, "=")
	ConsoleWrite("+ Summary")
	_TestFmkSummary()
EndFunc
_RunAllTests_CrucialSetupWizard()