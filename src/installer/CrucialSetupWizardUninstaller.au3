#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\img\installer.ico
#AutoIt3Wrapper_Outfile_x64=..\..\.out\CrucialSetupWizardUninstaller.exe
#AutoIt3Wrapper_Res_Comment=An AutoIt library for building installer and uninstaller GUIs
#AutoIt3Wrapper_Res_Description=Crucial Setup Wizard Uninstaller
#AutoIt3Wrapper_Res_Fileversion=1.2.0
#AutoIt3Wrapper_Res_ProductName=Crucial Setup Wizard
#AutoIt3Wrapper_Res_ProductVersion=1.2.0
#AutoIt3Wrapper_Res_CompanyName=Crucial Thread
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#AutoIt3Wrapper_Res_SaveSource=y
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

; This install script requires admin but a #RequireAdmin trigger a UAC prompt at interpreted runtime, which breaks testing
; So it is using a compile-time directive instead
#pragma compile(ExecLevel, requireAdministrator)

#include <FileConstants.au3>
#include <File.au3>
#include "CrucialSetupWizInstallShared.au3"

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialSetupWizardUninstaller.au3
; Version .......: 1.2.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Uninstaller for Crucial Setup Wizard.
;                  Reads installation paths from the registry written by CrucialSetupWizardInstaller.au3,
;                  removes all installed files, cleans up the AutoIt include registry entry,
;                  and removes the Add/Remove Programs entry.
;                  Removes the Vendor folder only if empty after uninstall.
;                  Removes the CrucialSetupWizard folder only if empty after uninstall.
;                  Removes only the CrucialSetupWizard path from the AutoIt include registry value _
;                  without affecting any other vendor paths registered there.
; Note ..........: Requires administrator rights to delete from Program Files.
; Note ..........: The uninstall steps in __RunUninstall are mocked when running as a _
;                  plain script outside of test mode ($__TFW_TEST_MODE not declared).
; ===============================================================================================================================

;================================================================================================================================
#Region ; Entry point
;================================================================================================================================

; Guardrail to not run the entry point in test mode, so the functions can be tested
If Not IsDeclared("__TFW_TEST_MODE") Then _MainUninstall()

Func _MainUninstall()
    If Not __ReadInstallRecord() Then
		_Tstbl_MsgBox($MB_OK + $MB_ICONERROR, $WIZ_UNINSTALLER_TITLE, _
			$WIZ_APP_NAME & " installation record was not found." & @CRLF & @CRLF & _
			"It may have already been uninstalled.")
        Return
    EndIf

    If __IsRunningFromInstallFolder() Then
        __RelaunchFromTemp()
        Return
    EndIf

	_InitWizard(__Uninstall())
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Read install record
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Reads the installation record from the registry written by CrucialSetupWizardInstaller.au3
; Populates $g_sIncludePath and $g_sInstallPath from the stored registry values.
; Returns    : True if both paths were read successfully, False if either registry read fails
; ===============================================================================================================================
Func __ReadInstallRecord()
    $g_sIncludePath = _Tstbl_RegRead($REG_INSTALL_KEY, "IncludePath")
    If @error Then Return False
    $g_sInstallPath = _Tstbl_RegRead($REG_INSTALL_KEY, "InstallPath")
    If @error Then Return False
    Return True
EndFunc

; #FUNCTION# ====================================================================================================================
; Checks whether the uninstaller executable is currently running from within the install folder.
; Used to detect the case where the uninstaller would delete itself mid-run.
; Returns    : True if @ScriptFullPath is inside $g_sInstallPath, False otherwise
; ===============================================================================================================================
Func __IsRunningFromInstallFolder()
    Return StringInStr(StringLower(@ScriptFullPath), StringLower($g_sInstallPath))
EndFunc

; #FUNCTION# ====================================================================================================================
; Copies the uninstaller executable to the system temp folder and launches it from there.
; Called when the uninstaller is running from within the install folder to avoid self-deletion.
; Returns    : None
; ===============================================================================================================================
Func __RelaunchFromTemp()
    Local $sTempExe = @TempDir & "\CrucialSetupWizardUninstaller.exe"
    _Tstbl_FileCopy(@ScriptFullPath, $sTempExe, $FC_OVERWRITE)
    _Tstbl_ShellExecute($sTempExe)
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Registry & Folder remove
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Removes $g_sIncludePath from the AutoIt Include registry value without affecting other registered paths.
; If the path is the only entry the registry value is deleted entirely; otherwise it is rewritten
; with the remaining paths. Resume if the Include registry doesn't exist already.
; Uses _OnErrorResume() as a TryCatch guard. Throws "RegDeleteException" when delete registry fails _
; or "RegWriteException" when write registry fails.
; Returns    : None on success, SetError on failure
; ===============================================================================================================================
Func __RemoveIncludeRegistry()
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

    ; If the Include registry entry doesn't exist then there is nothing to be done
	Local $sExisting = _Tstbl_RegRead($REG_AUTOIT_INCLUDE, "Include")
    If @error Then Return

    Local $aPaths = StringSplit($sExisting, ";", $STR_ENTIRESPLIT)
    Local $sNew = ""
    For $i = 1 To $aPaths[0]
        Local $sPath = StringStripWS($aPaths[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)
        If $sPath <> "" And StringLower($sPath) <> StringLower($g_sIncludePath) Then
            $sNew &= ($sNew = "") ? $sPath : ";" & $sPath
        EndIf
    Next

    If $sNew = "" Then
        Local $iRegDel = _Tstbl_RegDelete($REG_AUTOIT_INCLUDE, "Include")
		If $iRegDel <> 1 Then
			Local $iExCode = _ThrowException("RegDeleteException", "Failed to remove registry key", __RemoveIncludeRegistry) Or 1
			Return SetError($iExCode, 0, False)
		EndIf
    Else
        local $iRegWrite = _Tstbl_RegWrite($REG_AUTOIT_INCLUDE, "Include", "REG_SZ", $sNew)
		If Not $iRegWrite Then
			Local $iExCode = _ThrowException("RegWriteException", "Failed to re-write the registry key", __RemoveIncludeRegistry) Or 1
			Return SetError($iExCode, 0, False)
		EndIf
    EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Deletes a registry key and treats it as already removed if it doesn't exist. If RegDelete() reports nothing was
; deleted, RegRead() is used to confirm the key is actually gone before treating it as success. Throws a
; "RegDeleteException" if the key still exists after that check, or if RegDelete() itself fails.
; $sKeyName    - Full registry key path to delete
; Returns      : True on success (including when the key was already gone), SetError on failure
; =================================================================================================================================
Func __RemoveRegistryKey($sKeyName)
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

	Local $iRegDelete = _Tstbl_RegDelete($sKeyName)
	Local $iErr = @error

	If Not $iErr And Not $iRegDelete Then
		_Tstbl_RegRead($sKeyName, "")
		$iErr = Not @error
	EndIf

	If Not $iErr Then Return True
	Local $iExCode = _ThrowException("RegDeleteException", "Failed to delete the registry key", __RemoveRegistryKey) Or 1
	Return SetError($iExCode, 0, False)
EndFunc

; #FUNCTION# ====================================================================================================================
; Removes the specified folder only if it contains no files.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "RemoveFolderException" on dir remove failure.
; $sFolder   - Full path of the folder to remove if empty
; Returns    : None on success or when folder is not empty, SetError on failure
; ===============================================================================================================================
Func __RemoveFolderIfEmpty($sFolder)
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

    Local $aSize = _Tstbl_DirGetSize($sFolder, $DIR_EXTENDED)
    If @error Or $aSize[1] <> 0 Then Return

	FileChangeDir(@TempDir)
	Local $iDirRemove = _Tstbl_DirRemove($sFolder)
	If Not $iDirRemove Then
		Local $iExCode = _ThrowException("RemoveFolderException", "Failed to remove folder: " & $sFolder, __RemoveFolderIfEmpty) Or 1
		Return SetError($iExCode, 0, False)
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Deletes a single installed file. Skips silently if the file does not exist.
; Uses _OnErrorResume() as a TryCatch guard. Throws a "RemoveFileException" on file delete failure.
; $sFilePath   - Full path of the file to delete
; Returns      : True on success, None if file does not exist, SetError on failure
; ===============================================================================================================================
Func __RemoveInstalledFile($sFilePath)
	If _OnErrorResume() Then Return SetError(__GetStackCount(), 0, False)

	; If the file doesn't exist already then there is nothing to be done
	If Not _Tstbl_FileExists($sFilePath) Then Return

	Local $iDelete = _Tstbl_FileDelete($sFilePath)
	If Not $iDelete Then
		Local $iExCode = _ThrowException("RemoveFileException", "Failed to delete file: " & $sFilePath, __RemoveInstalledFile) Or 1
		Return SetError($iExCode, 0, False)
	EndIf

	Return True
EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================

;================================================================================================================================
#Region ; Uninstall logic
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Executes the full 6-step uninstall sequence: removes all library files, the CHM help file, and the
; uninstaller executable; cleans the AutoIt include registry entry; removes the Vendor and CrucialSetupWizard
; folders if empty; and deletes the install and Add/Remove Programs registry keys.
; In uncompiled script mode (outside of test mode) all file and registry steps are skipped and a mock
; message is written to the console instead.
; Wraps all steps in a TryCatch block; any thrown exception aborts the uninstall and returns False.
; Note ..........: Called by the wizard Progress page to execute the uninstallation steps.
; $idStatusLabel - Control ID of the progress status label
; $idProgress    - Control ID of the progress bar
; Returns    	 : True on success, False on failure or when not running as admin in compiled mode
; ===============================================================================================================================
Func __RunUninstall($idStatusLabel, $idProgress)
	If @Compiled And Not _Tstbl_IsAdmin() Then Return False

	Local $bSkip = (Not @Compiled And Not IsDeclared("__TFW_TEST_MODE"))? True : False

	_Try()
		Local $iStep  = 0
		Local $iSteps = 6

		If $bSkip then ConsoleWrite("- ### [MOCKING] function __RunUninstall ### " & @CRLF)

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Removing " & $WIZ_APP_NAME & " files...")
        If Not $bSkip Then
			__RemoveInstalledFile($g_sIncludePath & "\CrucialSetupWizard.au3")
			__RemoveInstalledFile($g_sIncludePath & "\CrucialWizTstblInclude.au3")
		EndIf
		$iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Updating AutoIt include registry entry...")
		If Not $bSkip Then __RemoveIncludeRegistry()
		$iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Removing CrucialSetupWizard.chm...")
		If Not $bSkip Then __RemoveInstalledFile($g_sInstallPath & "\CrucialSetupWizard.chm")
		If Not $bSkip Then __RemoveInstalledFile($g_sInstallPath & "\CrucialSetupWizardUninstaller.exe")
		$iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Removing " & $WIZ_APP_NAME & " registry entries...")
		If Not $bSkip Then __RemoveRegistryKey($REG_INSTALL_KEY)
		If Not $bSkip Then __RemoveRegistryKey($REG_UNINSTALL_KEY)
        $iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Removing Vendor folder if empty...")
		If Not $bSkip Then __RemoveFolderIfEmpty($g_sIncludePath)
		$iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Removing CrucialSetupWizard folder if empty...")
		If Not $bSkip Then __RemoveFolderIfEmpty($g_sInstallPath)
		$iStep += 1

		__UpdateProgressBar($idStatusLabel, $idProgress, $iStep, $iSteps, "Finished!")

		Local $e
		If _Catch($e) Then
			_Tstbl_MsgBox($MB_OK + $MB_ICONERROR, $WIZ_APP_NAME, _StackTrace(_FormatStackTrace))
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
#Region ; Uninstall Wizard Setup
;================================================================================================================================

; #FUNCTION# ====================================================================================================================
; Builds and returns the summary text displayed on the Ready to Uninstall page.
; Lists all actions the uninstaller will perform, using the current values of $g_sIncludePath and $g_sInstallPath.
; Returns    : String containing the formatted list of uninstallation steps
; ===============================================================================================================================
Func _UninstallUpdateReadyPage()
    Local $sReadyText = ""
    $sReadyText &= " - Delete CrucialSetupWizard.au3 from: " & $g_sIncludePath & @CRLF
    $sReadyText &= " - Remove include path from AutoIt registry entry" & @CRLF
    $sReadyText &= " - Remove Vendor folder if empty" & @CRLF
    $sReadyText &= " - Delete CrucialSetupWizard.chm from: " & $g_sInstallPath & @CRLF
    $sReadyText &= " - Remove CrucialSetupWizard folder if empty" & @CRLF
    $sReadyText &= " - Remove from Add/Remove Programs"
	Return $sReadyText
EndFunc

; #FUNCTION# ====================================================================================================================
; Creates and configures the full 4-page uninstall wizard: Welcome, Ready to Uninstall, Progress, and Finish.
; Sets the Apply button caption to "Uninstall" via the installer config.
; Returns    : Wizard map ($mWizard) ready to be passed to _InitWizard()
; ===============================================================================================================================
Func __Uninstall()

	Local $mCfg = _NewInstallerCfg(_NewWndCfg(638, 407))
	$mCfg.sBtnCaptApply = "Uninstall"

	Local $sUninstallerTitle = $WIZ_UNINSTALLER_TITLE
	Local $sHeaderTitle = $WIZ_APP_NAME
	Local $mWizard = _NewWizard($mCfg, $sUninstallerTitle, $sHeaderTitle)

    ; ===================================================================
    ; Page 1 - Welcome
    ; ===================================================================
    Local $sIntroText = "This process will remove " & $WIZ_APP_NAME & " from your computer." & @CRLF & @CRLF & _
        "Current installation:" & @CRLF & @CRLF & _
        " Library: " & $g_sIncludePath & @CRLF & _
        " Documentation: " & $g_sInstallPath & @CRLF & @CRLF & _
        "Click Next to continue or Cancel to exit."
	Local $sIntroSubHeading = "Welcome to " & $WIZ_UNINSTALLER_TITLE
	Local $iIntroPageId = _AddIntroPage($mWizard, $mCfg, $sIntroText, $sIntroSubHeading, "")

    ; ===================================================================
    ; Page 2 - Ready to Uninstall
    ; ===================================================================
	Local $sReadyInfo = ""
	Local $sReadySubHeading = "Ready to uninstall"
	Local $iReadyPageId = _AddReadyPage($mWizard, $mCfg, $sReadyInfo, $sReadySubHeading, _UninstallUpdateReadyPage)

    ; ===================================================================
    ; Page 3 - Progress
    ; ===================================================================
	Local $sProgressSubHeading = "Uninstalling, please wait..."
	Local $sFailureMsg = "Uninstallation failed. Please try again."
	Local $iProgressPageId = _AddProgressPage($mWizard, $mCfg, __RunUninstall, $sFailureMsg, $sProgressSubHeading)

    ; ===================================================================
    ; Page 4 - Finish
    ; ===================================================================
	Local $idLblProgress = _GetPageCtrl(_GetWizardPage($mWizard, $iProgressPageId), "LblProgress")
	Local $idProgressbar = _GetPageCtrl(_GetWizardPage($mWizard, $iProgressPageId), "Progressbar")

	Local $sFinishMsg = $WIZ_APP_NAME & " has been successfully uninstalled." & @CRLF & @CRLF & _
						"Thank you for using " & $WIZ_APP_NAME & "."

	Local $sFinishSubHeading = "Uninstallation complete"
	Local $iFinishPageId = _AddFinishPage($mWizard, $mCfg, $idLblProgress, $idProgressbar, $sFinishMsg, Default, $sFinishSubHeading)

	Return $mWizard

EndFunc

;================================================================================================================================
#EndRegion <<<
;================================================================================================================================