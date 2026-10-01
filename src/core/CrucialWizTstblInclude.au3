#include-once

#include <Testable.au3>

; #INDEX# =======================================================================================================================
; Title .........: Crucial Setup Wizard - CrucialWizTstblInclude.au3
; Version .......: 1.0.0
; AutoIt Version : 3.3.18.0
; Language ......: English
; Author ........: Crucial Thread
; Description ...: Bridges CrucialSetupWizard.au3 to Testable.au3 from AutoIt Test Framework. Kept in its own
;                  file so the include path can vary by installation method without changing
;                  CrucialSetupWizard.au3 itself, and so the installer can detect whether AutoIt Test
;                  Framework is present at the install destination before copying any files.
; Note ..........: This is the REGULAR version, using a global #include <Testable.au3>. It is used when
;                  Crucial Setup Wizard is installed via the installer or copied into a project folder.
;                  A separate version on the `dist` git branch uses a relative #include instead, for when
;                  AutoIt Test Framework is provided as a sibling Git submodule.
; ===============================================================================================================================