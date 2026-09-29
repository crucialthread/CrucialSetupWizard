#include-once

; #INDEX# =======================================================================================================================
; Title .........: AutoIt Test Framework - TestFmkInstallerConstants.au3
; Version .......: 1.0.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: AutoIt Test Framework Installer/Uninstaller shared constants and globals .
; ===============================================================================================================================

; ===============================================================================================================================
; Constants
; ===============================================================================================================================

Global Const $WIZ_INSTALLER_VERSION = "1.0.0"
Global Const $WIZ_UNINSTALLER_TITLE = "AutoIt Test Framework Uninstall"

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
