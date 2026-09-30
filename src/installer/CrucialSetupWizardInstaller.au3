#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\img\installer.ico
#AutoIt3Wrapper_Outfile_x64=..\..\.out\CrucialSetupWizardInstaller.exe
#AutoIt3Wrapper_Res_Comment=An AutoIt library for building installer and uninstaller GUIs
#AutoIt3Wrapper_Res_Description=Crucial Setup Wizard Installer
#AutoIt3Wrapper_Res_Fileversion=0.0.1.0
#AutoIt3Wrapper_Res_ProductName=Crucial Setup Wizard
#AutoIt3Wrapper_Res_ProductVersion=0.0.1
#AutoIt3Wrapper_Res_CompanyName=Crucial Thread
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Add_Constants=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; This install script requires admin but a #RequireAdmin trigger a UAC prompt at interpreted runtime, which breaks testing
; So it is using a compile-time directive instead
#pragma compile(ExecLevel, requireAdministrator)

#include <FileConstants.au3>
#include "CrucialSetupWizInstallConstants.au3"
#include "..\core\CrucialSetupWizard.au3"
#include "..\..\lib\TryCatch\TryCatch.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialSetupWizardInstaller.au3
; Version .......: 0.0.1
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Installation wizard for Crucial Setup Wizard.
;                  Copies CrucialSetupWizard.au3, and CrucialWizTstblInclude.au3 files to the _
;                  AutoIt Vendor include folder and registers the path in the AutoIt include _
;                  registry so the library is available from any project via:
;                  #include <CrucialSetupWizard.au3>.
;                  Detects the AutoIt installation folder from the registry.
;                  Detects existing installations and upgrades automatically.
;                  Registers itself in Add/Remove Programs for uninstall support.
; Note ..........: Requires administrator rights to write to Program Files.
; Note ..........: All files are embedded into the compiled .exe via FileInstall at _
;                  compile time. The compiled .exe is fully self-contained.
; Note ..........: The installation steps in __RunInstall are mocked when running as a _
;                  plain script outside of test mode ($__TFW_TEST_MODE not declared).
; ===============================================================================================================================

;================================================================================================================================
#Region ; Entry point
;================================================================================================================================

; Guardrail to not run the entry point in test mode, so the functions can be tested
If Not IsDeclared("__TFW_TEST_MODE") Then _MainInstall()

Func _MainInstall()
    __DetectPaths()
    __CheckExistingInstall()
	_InitWizard(__Installation())
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Detection
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Detects the AutoIt installation directory from the registry and derives the default include and install paths.
; Reads HKLM WOW6432Node first, then falls back to the standard AutoIt key, then to a hardcoded default.
; Sets $g_sAutoItDir, $g_sIncludePath, and $g_sInstallPath.
; Returns    : None
; ===============================================================================================================================
Func __DetectPaths()
    $g_sAutoItDir = _Tstbl_RegRead($REG_AUTOIT_KEY_WOW, "InstallDir")
    If @error Then $g_sAutoItDir = _Tstbl_RegRead($REG_AUTOIT_KEY, "InstallDir")
    If @error Then $g_sAutoItDir = "C:\Program Files (x86)\AutoIt3"

    $g_sIncludePath = $g_sAutoItDir & "\Include\Vendor"
    $g_sInstallPath = $g_sAutoItDir & "\CrucialSetupWizard"
EndFunc

; #FUNCTION# ====================================================================================================================
; Checks whether a previous installation exists in the registry and sets the upgrade flag accordingly.
; If an existing installation is found, pre-populates $g_sIncludePath and $g_sInstallPath from the
; stored registry values, provided the recorded paths still exist on disk.
; Sets $g_bIsUpgrade to True when a prior version entry is detected.
; Returns    : None
; ===============================================================================================================================
Func __CheckExistingInstall()
    Local $sExistingVersion = _Tstbl_RegRead($REG_INSTALL_KEY, "Version")
    $g_bIsUpgrade = Not @error And $sExistingVersion <> ""

    If $g_bIsUpgrade Then
        Local $sExistingInclude = _Tstbl_RegRead($REG_INSTALL_KEY, "IncludePath")
		If Not @error And _Tstbl_FileExists($sExistingInclude) Then $g_sIncludePath = $sExistingInclude

        Local $sExistingInstall = _Tstbl_RegRead($REG_INSTALL_KEY, "InstallPath")
        If Not @error And _Tstbl_FileExists($sExistingInstall) Then $g_sInstallPath = $sExistingInstall
    EndIf
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Registry writers
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Appends $g_sIncludePath to the AutoIt Include registry value so AutoIt can resolve #include <CrucialSetupWizard.au3>.
; Reads the existing Include value and skips the write if the path is already present.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "WriteIncludeRegistry" exception on write failure.
; Returns    : None on success, SetError on failure
; ===============================================================================================================================
Func __WriteIncludeRegistry()
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

    Local $sExisting = _Tstbl_RegRead($REG_AUTOIT_INCLUDE, "Include")
    If @error Then $sExisting = ""
    If Not StringInStr($sExisting, $g_sIncludePath) Then
        Local $sNew = ($sExisting = "") ? $g_sIncludePath : $sExisting & ";" & $g_sIncludePath
        Local $iReturnRegWrite = _Tstbl_RegWrite($REG_AUTOIT_INCLUDE, "Include", "REG_SZ", $sNew)
		If Not $iReturnRegWrite Then
			Local $iExCode = _ThrowException("WriteIncludeRegistry", "Failed to write Include registry: " & $sNew, __WriteIncludeRegistry) Or 1
			Return SetError($iExCode, 0, False)
		EndIf
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Writes the installation record (Version, IncludePath, InstallPath) to the Crucial Setup Wizard registry key.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "WriteInstallRegistry" exception if any write fails.
; Returns    : None on success, SetError on failure
; ===============================================================================================================================
Func __WriteInstallRegistry()
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

	Local $iReturnRegWrite = True
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_INSTALL_KEY, "Version",     "REG_SZ", $WIZ_INSTALLER_VERSION)
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_INSTALL_KEY, "IncludePath", "REG_SZ", $g_sIncludePath)
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_INSTALL_KEY, "InstallPath", "REG_SZ", $g_sInstallPath)

	If Not $iReturnRegWrite Then
		Local $iExCode = _ThrowException("WriteInstallRegistry", "Failed to write Install registry", __WriteInstallRegistry) Or 1
		Return SetError($iExCode, 0, False)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Writes the Add/Remove Programs entries for the library, including DisplayName, DisplayVersion,
; Publisher, UninstallString, and NoModify.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "WriteUninstallRegistry" exception if any write fails.
; Returns    : None on success, SetError on failure
; ===============================================================================================================================
Func __WriteUninstallRegistry()
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

    Local $sUninstallerPath = $g_sInstallPath & "\CrucialSetupWizardUninstaller.exe"

	Local $iReturnRegWrite = True
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_UNINSTALL_KEY, "DisplayName",     "REG_SZ",    "Crucial Setup Wizard")
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_UNINSTALL_KEY, "DisplayVersion",  "REG_SZ",    $WIZ_INSTALLER_VERSION)
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_UNINSTALL_KEY, "Publisher",       "REG_SZ",    "Crucial Thread")
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_UNINSTALL_KEY, "UninstallString", "REG_SZ",    '"' & $sUninstallerPath & '"')
    $iReturnRegWrite = $iReturnRegWrite And _Tstbl_RegWrite($REG_UNINSTALL_KEY, "NoModify",        "REG_DWORD", 1)

	If Not $iReturnRegWrite Then
		Local $iExCode = _ThrowException("WriteUninstallRegistry", "Failed to write Uninstall registry", __WriteUninstallRegistry) Or 1
		Return SetError($iExCode, 0, False)
	EndIf
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; FileInstall Implementation (required by testable)
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; __FileInstall wraps FileInstall with literal string paths as required by TestableFileInstall.au3 so Aut2Exe can find _
; and embed all files at compile time, while still allowing the function to be stubbed in tests.
; $sSource     - Source path string; must match one of the known literal cases
; $sDest       - Destination path passed through to FileInstall
; $iFlag       - Overwrite flag passed through to FileInstall
; Returns    : 1 on success, 0 if $sSource did not match any known case or the copy failed
; ===============================================================================================================================
Func __FileInstall($sSource, $sDest, $iFlag)

	Local $iFileInstall = 0

    Select
        Case $sSource = "..\core\CrucialSetupWizard.au3"
            $iFileInstall = FileInstall("..\core\CrucialSetupWizard.au3", $sDest, $iFlag)

        Case $sSource = "..\core\CrucialWizTstblInclude.au3"
            $iFileInstall = FileInstall("..\core\CrucialWizTstblInclude.au3", $sDest, $iFlag)

        Case $sSource = "..\..\chm\CrucialSetupWizard.chm"
            $iFileInstall = FileInstall("..\..\chm\CrucialSetupWizard.chm", $sDest, $iFlag)

        Case $sSource = "..\..\.out\CrucialSetupWizardUninstaller.exe"
            $iFileInstall = FileInstall("..\..\.out\CrucialSetupWizardUninstaller.exe", $sDest, $iFlag)
	EndSelect

	Return $iFileInstall
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Installation logic
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Copies a single framework file to its destination using _Tstbl_FileInstall.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "FileInstallException" exception on FileInstall failure.
; $sSource     - Source path of the file to install
; $sDest       - Destination path
; $iFlag       - Overwrite flag (e.g. $FC_OVERWRITE)
; Returns      : True on success, SetError on failure
; Note.........: Needs the _Tstbl_FileInstall be implemented through _Tstbl_Implement_FileInstall before usage
; ===============================================================================================================================
Func __InstallFile($sSource, $sDest, $iFlag)
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

	Local $iFileInstall = _Tstbl_FileInstall($sSource, $sDest, $iFlag)
	If Not $iFileInstall Then
		Local $iExCode = _ThrowException("FileInstallException", "Failed to include file: " & $sSource, __InstallFile) Or 1
		Return SetError($iExCode, 0, False)
	EndIf

	Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Executes the full 6-step installation sequence: creates folders, copies all library files, the CHM help _
; file, and the uninstaller, then writes the include, install, and uninstall registry entries.
; In uncompiled script mode (outside of test mode) all file and registry steps are skipped and a mock
; message is written to the console instead.
; Wraps all steps in a TryCatch block; any thrown exception aborts the install and returns False.
; Note ..........: Called by the wizard Progress page to execute the installation steps.
; Note ..........: Registers the custom FileInstall function via _Tstbl_Implement_FileInstall as required by Testable.
; $idStatusLabel - Control ID of the progress status label
; $idProgress    - Control ID of the progress bar
; Returns    	 : True on success, False on failure or when not running as admin in compiled mode
; ===============================================================================================================================
Func __RunInstall($idStatusLabel, $idProgress)
	If @Compiled And Not _Tstbl_IsAdmin() Then Return False

	_Tstbl_Implement_FileInstall(__FileInstall)

	Local $bSkip = (Not @Compiled And Not IsDeclared("__TFW_TEST_MODE"))? True : False

    _Try()
        Local $iStep  = 0
        Local $iSteps = 6

		If $bSkip then ConsoleWrite("- ### [MOCKING] function __RunInstall ### " & @CRLF)

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Creating install folders...")
		If Not $bSkip Then
			_TryWith(_NoErr() ? _Tstbl_DirCreate($g_sIncludePath) : Null)
			_TryWith(_NoErr() ? _Tstbl_DirCreate($g_sInstallPath) : Null)
		EndIf
        $iStep += 1

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Copying Crucial Setup Wizard files...")
        If Not $bSkip Then
			__InstallFile("..\core\CrucialWizTstblInclude.au3", $g_sIncludePath & "\CrucialWizTstblInclude.au3", $FC_OVERWRITE)
			__InstallFile("..\core\CrucialSetupWizard.au3", $g_sIncludePath & "\CrucialSetupWizard.au3", $FC_OVERWRITE)
		EndIf
        $iStep += 1

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Copying CrucialSetupWizard.chm...")
        If Not $bSkip Then __InstallFile("..\..\chm\CrucialSetupWizard.chm", $g_sInstallPath & "\CrucialSetupWizard.chm", $FC_OVERWRITE)
        $iStep += 1

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Copying CrucialSetupWizardUninstaller.exe...")
        If Not $bSkip Then __InstallFile("..\..\.out\CrucialSetupWizardUninstaller.exe", $g_sInstallPath & "\CrucialSetupWizardUninstaller.exe", $FC_OVERWRITE)
        $iStep += 1

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Writing AutoIt include registry entry...")
        If Not $bSkip Then __WriteIncludeRegistry()
        $iStep += 1

        _ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Finalizing installation...")
        If Not $bSkip Then
			__WriteInstallRegistry()
			__WriteUninstallRegistry()
		EndIf
        $iStep += 1

		_ProgressStep($idStatusLabel, $idProgress, $iStep, $iSteps, "Finished!")

		Local $e
		If _Catch($e) Then
			_Tstbl_ConsoleWrite("!" & _StackTrace(_FormatStackTrace) & @CRLF)
			_EndTry()
			Return False
		EndIf
    _EndTry()
    Return True
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Install Wizard Setup
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Reads the include path input control and updates $g_sIncludePath with the current value.
; Called as a change callback from the path wizard page to updated the include path when it is updated.
; $idInputPath - Control ID of the input field containing the chosen include path
; Returns    : None
; ===============================================================================================================================
Func _UpdateIncludePath($idInputPath)
	$g_sIncludePath = _Tstbl_GUICtrlRead($idInputPath)
EndFunc

; #FUNCTION# ====================================================================================================================
; Builds and returns the summary text displayed on the Ready to Install page.
; Lists all actions the installer will perform, using the current values of $g_sIncludePath and $g_sInstallPath.
; Returns    : String containing the formatted list of installation steps
; ===============================================================================================================================
Func _UpdateReadyPage()
    Local $sText = ""
    $sText &= " - Create folder (if needed): " & $g_sIncludePath & @CRLF
    $sText &= " - Copy CrucialSetupWizard.au3 to: " & $g_sIncludePath & @CRLF
    $sText &= " - Create folder (if needed): " & $g_sInstallPath & @CRLF
    $sText &= " - Copy CrucialSetupWizard.chm to: " & $g_sInstallPath & @CRLF
    $sText &= " - Copy CrucialSetupWizardUninstaller.exe to: " & $g_sInstallPath & @CRLF
    $sText &= " - Create AutoIt registry entry for include path"
	Return $sText
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates and configures the full 5-page installation wizard: Welcome, Install Path, Ready to Install,
; Progress, and Finish.
; Reads $g_bIsUpgrade to adjust the welcome page text and heading for upgrade vs. fresh install.
; Returns    : Wizard map ($mWizard) ready to be passed to _InitWizard()
; ===============================================================================================================================
Func __Installation()
	Local $mCfg = _NewInstallerCfg(_NewWndCfg(580, 370))
	Local $sInstallerTitle = "Crucial Setup Wizard"
	Local $sHeaderTitle = "Crucial Setup Wizard"
	Local $mWizard = _NewWizard($mCfg, $sInstallerTitle, $sHeaderTitle)

    ; ===================================================================
    ; Page 1 - Welcome
    ; ===================================================================
    Local $sIntroText = $g_bIsUpgrade ? _
        "Welcome to the Crucial Setup Wizard." & @CRLF & @CRLF & _
        "This process will upgrade Crucial Setup Wizard on your computer." & @CRLF & @CRLF & _
        "Click Next to continue or Cancel to exit." : _
        "Welcome to the Crucial Setup Wizard." & @CRLF & @CRLF & _
        "This process will install Crucial Setup Wizard on your computer," & @CRLF & _
        "making it available from any AutoIt project via:" & @CRLF & @CRLF & _
        " #include <CrucialSetupWizard.au3>" & @CRLF & @CRLF & _
        "Click Next to continue or Cancel to exit."

	Local $sIntroSubHeading = ($g_bIsUpgrade ? "Upgrading " : "Install ") & $sHeaderTitle
	Local $iIntroPageId = _AddIntroPage($mWizard, $mCfg, $sIntroText, $sIntroSubHeading, $WIZ_INSTALLER_VERSION)

    ; ===================================================================
    ; Page 2 - Install Path
    ; ===================================================================
    Local $sPathPageInfo = "CrucialSetupWizard.au3 will be copied to the folder below." & @CRLF & @CRLF & _
						   "A registry entry will be created so AutoIt finds it automatically" & @CRLF & _
						   "using #include <CrucialSetupWizard.au3> from any project."

	Local $sPathLabel = "Install folder:"
	Local $sPathSubHeading = "Choose install folder"
	Local $iPathPageId = _AddPathPage($mWizard, $mCfg, $g_sInstallPath, _UpdateIncludePath, $sPathLabel, $sPathPageInfo, $sPathSubHeading)

    ; ===================================================================
    ; Page 3 - Ready to Install
    ; ===================================================================
	Local $sReadyInfo = ""
	Local $sReadySubHeading = "Ready to install"
	Local $iReadyPageId = _AddReadyPage($mWizard, $mCfg, $sReadyInfo, $sReadySubHeading, _UpdateReadyPage)

    ; ===================================================================
    ; Page 4 - Progress
    ; ===================================================================
	Local $sProgressSubHeading = "Installing, please wait..."
	Local $sFailureMsg = "Installation failed. Please try again."
	Local $iProgressPageId = _AddProgressPage($mWizard, $mCfg, __RunInstall, $sFailureMsg, $sProgressSubHeading)

    ; ===================================================================
    ; Page 5 - Finish
    ; ===================================================================
	Local $idLblProgress = _GetPageCtrl(_GetWizardPage($mWizard, $iProgressPageId), "LblProgress")
	Local $idProgressbar = _GetPageCtrl(_GetWizardPage($mWizard, $iProgressPageId), "Progressbar")
	Local $sDocFile = $g_sInstallPath & "\CrucialSetupWizard.chm"

	Local $sFinishMsg = "Crucial Setup Wizard has been successfully installed." & @CRLF & @CRLF & _
						"You can now use it from any AutoIt project:" & @CRLF & _
						" #include <CrucialSetupWizard.au3>"

	Local $sFinishSubHeading = "Installation complete"
	Local $iFinishPageId = _AddFinishPage($mWizard, $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg, $sDocFile, $sFinishSubHeading)

	Return $mWizard
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================
