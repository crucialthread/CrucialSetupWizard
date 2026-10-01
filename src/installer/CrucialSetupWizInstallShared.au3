#include-once

#include "..\core\CrucialSetupWizard.au3"
#include "..\..\lib\TryCatch\TryCatch.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialSetupWizInstallShared.au3
; Version .......: 1.1.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Crucial Setup Wizard Installer/Uninstaller shared constants, globals, and functions.
; ===============================================================================================================================

; ===============================================================================================================================
; Constants
; ===============================================================================================================================

Global Const $WIZ_INSTALLER_VERSION = "1.1.0"
Global Const $WIZ_APP_NAME 			= "Crucial Setup Wizard"
Global Const $WIZ_UNINSTALLER_TITLE = $WIZ_APP_NAME & " Uninstall"

Global Const $REG_UNINSTALL_KEY  = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\CrucialSetupWizard"
Global Const $REG_INSTALL_KEY    = "HKEY_LOCAL_MACHINE\SOFTWARE\CrucialSetupWizard"
Global Const $REG_AUTOIT_KEY_WOW = "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\AutoIt v3\AutoIt"
Global Const $REG_AUTOIT_KEY     = "HKEY_LOCAL_MACHINE\SOFTWARE\AutoIt v3\AutoIt"
Global Const $REG_AUTOIT_INCLUDE = "HKEY_CURRENT_USER\Software\AutoIt v3\AutoIt"

; ===============================================================================================================================
; Global state
; ===============================================================================================================================

Global $g_sAutoItDir   = ""
Global $g_sIncludePath = ""
Global $g_sInstallPath = ""
Global $g_bIsUpgrade   = False

; #FUNCTION# ====================================================================================================================
; An unitility wrap-up to _ProgressStep that does not update progressbar if an exception was thrown
; ===============================================================================================================================
Func __UpdateProgressBar($idLabel, $idProgress, $iStep, $iSteps, $sStatus)
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)
	_ProgressStep($idLabel, $idProgress, $iStep, $iSteps, $sStatus)
EndFunc
