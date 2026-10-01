# Crucial Setup Wizard

An AutoIt library for building installer and uninstaller GUIs. Five ready-made page templates cover the common install flow, built from reusable pieces that make it just as easy to build pages of your own, with a single flat config map that drives layout, fonts and buttons, and custom event handlers that let you hook into any page.

See the full [documentation](https://crucialthread.github.io/CrucialSetupWizard/) for more details.

## Features

- **Five ready-made pages for the whole flow** - intro, path selection with a Browse dialog, ready/confirm, progress, and finish, each pre-wired and ready to use out of the box
- **Flexible by design** - use the five page templates as they are, customize the pieces you need, or build a page entirely your own from the same controls, event handlers and buttons the templates are made of
- **Configure once, apply everywhere** - window sizing, fonts and button captions combine into a single config you build once and pass to every page and control, overriding only what you need while everything else falls back to defaults
- **Custom event hooks** - `OnLoad`/`AfterLoad`/`OnClose`/`OnClick` events are handled by reusable handler functions, so you can plug in a ready-made one, swap it for another, or write your own, all using the same simple mechanism
- **Self-managing buttons** - Cancel/Back/Next enable state and caption switch automatically based on each page's status
- **Visible progress you control** - drive a multi-step install or uninstall process with a progress bar and status text that update in real time
- **Reliable, and easy to troubleshoot** - invalid input is caught before it can crash the wizard, and reported with a clear message, including console output during development that points straight to what's wrong

## Quick Example

```autoit
#include <CrucialSetupWizard.au3>

Func _InstallApp($idLblProgress, $idProgressbar)
    _ProgressStep($idLblProgress, $idProgressbar, 0, 1, "Copying files...")
    FileCopy(@ScriptDir & "\app.exe", @ProgramFilesDir & "\MyApp\app.exe", 9)
    Return True
EndFunc

Local $mCfg = _NewInstallerCfg()
Local $mWizard = _NewWizard($mCfg, "MyApp Setup", "MyApp Setup Wizard")

_AddIntroPage($mWizard, $mCfg, "This wizard will install MyApp on your computer.")
_AddPathPage($mWizard, $mCfg, @ProgramFilesDir & "\MyApp", Default)
_AddReadyPage($mWizard, $mCfg, "Ready to install MyApp.")

Local $iProgress = _AddProgressPage($mWizard, $mCfg, _InstallApp)
Local $mProgressPage = _GetWizardPage($mWizard, $iProgress)
_AddFinishPage($mWizard, $mCfg, _GetPageCtrl($mProgressPage, "LblProgress"), _
    _GetPageCtrl($mProgressPage, "Progressbar"), "MyApp has been installed successfully.")

_InitWizard($mWizard)
```

## Installation

### Dependency

Crucial Setup Wizard requires [AutoIt Test Framework](https://github.com/crucialthread/AutoItTestFramework) to be installed since its built-in functions follow AutoIt Test Framework's testable-function pattern.

### Option 1 - Installer (recommended)

Download the latest installer from the [releases page](https://github.com/crucialthread/CrucialSetupWizard/releases) and run it. It copies `CrucialSetupWizard.au3` to your AutoIt Vendor include folder and configures the registry automatically, making it available from any project via:

```autoit
#include <CrucialSetupWizard.au3>
```

The installer also includes the documentation (`CrucialSetupWizard.chm`) and an uninstaller registered in Add/Remove Programs - itself built with Crucial Setup Wizard.

> **Note:** the installer requires administrator rights to write to the AutoIt installation folder.

> ⚠️ **Windows security warning:** Windows may show a SmartScreen warning when running the installer for the first time since it is not digitally signed. This is expected for open source tools distributed outside the Microsoft Store. You can proceed in one of two ways:
> - Click **More info** then **Run anyway** on the SmartScreen dialog
> - Right-click the downloaded `.exe` > **Properties** > check **Unblock** at the bottom > click OK, then run it normally
>
> If you prefer not to run the installer, you can install manually by downloading and extracting the source code zip from the releases page, copying `src/core/*.au3` into your project folder, and following Option 2 below.

### Option 2 - Local project folder

Download and extract the source code zip from the [releases page](https://github.com/crucialthread/CrucialSetupWizard/releases), copy `src/core/CrucialSetupWizard.au3` and `src/core/CrucialWizTstblInclude.au3` into your project folder, and reference it with a relative path:

```autoit
#include "CrucialSetupWizard.au3"
```

This is the simplest option but means you need a separate copy for each project (or you can keep it in a shared folder from where all your projects reference it).

> **Note:** `CrucialWizTstblInclude.au3` expects it installed globally (`#include <Testable.au3>`). If you'd rather not install it globally, edit `CrucialWizTstblInclude.au3` to point wherever you keep `Testable.au3` instead.

### Option 3 - Git submodule (advanced, recommended for Git projects)

If your project is a Git repository, you can add Crucial Setup Wizard as a submodule directly from the `dist` branch. This gives you `CrucialSetupWizard.au3` with no extra content from the development repo, and lets you pin to a specific version and update deliberately when you are ready.

Crucial Setup Wizard expects AutoIt Test Framework to also be provided as a Git submodule, at `lib/TestFramework` sibling to wherever you submodule Crucial Setup Wizard - feel free to add it that way, or to edit `CrucialWizTstblInclude.au3` to point wherever you keep `Testable.au3` instead.

**Step 1 - Add the submodule:**

```bash
git submodule add -b dist https://github.com/crucialthread/CrucialSetupWizard lib/CrucialSetupWizard
git submodule update --init
```

**Step 2 - Add AutoIt Test Framework as a submodule (skip this if you edited `CrucialWizTstblInclude.au3` to point elsewhere instead):**

```bash
git submodule add -b dist https://github.com/crucialthread/AutoItTestFramework lib/TestFramework
git submodule update --init
```

**Step 3 - Reference it from your script:**

```autoit
#include "lib/CrucialSetupWizard/CrucialSetupWizard.au3"
```

**Cloning a project that already uses the submodule:**

```bash
git clone --recurse-submodules https://github.com/youruser/YourProject
```

Or if you already cloned without it:

```bash
git submodule update --init
```

**Updating to a newer version when ready:**

```bash
git submodule update --remote lib/CrucialSetupWizard
git add lib/CrucialSetupWizard
git commit -m "Update Crucial Setup Wizard to latest"
```

## Troubleshooting

### Conflict between global installation and Git submodule

If you have Crucial Setup Wizard installed globally (via the installer) and are working on a Git project that also includes it as a submodule, you may get duplicate declaration errors at runtime. This happens because AutoIt sees two copies of the same file from different paths.

To resolve this, uninstall the global installation via Add/Remove Programs and use the submodule reference for that project. Then install it locally as described in Option 2, and any other scripts that previously used the angle-bracket form will need to be updated to reference the file directly.

## Usage

See the [documentation](https://crucialthread.github.io/CrucialSetupWizard/) for the full concepts guide, function reference, and a complete worked example.

## API

**Configuration**

| Function | Description |
|---|---|
| `_NewWndCfg()` | Creates a window dimension config map. |
| `_NewFontCfg()` | Creates a font config map. |
| `_NewBtnDim()` | Creates a button dimension config map. |
| `_NewBtnCaptions()` | Creates a button captions config map. |
| `_NewBtnCfg()` | Combines button dimensions and captions into one map. |
| `_NewInstallerCfg()` | Combines window, font and button configs into the single flat map every other function reads from. |

**Installer Events**

| Function | Description |
|---|---|
| `_GetInstallerEvent()` | Returns the current installer event state. |
| `_SetInstallerEvent()` | Sets the current installer event state. |

**Pages**

| Function | Description |
|---|---|
| `_CreatePages()` | Creates an empty pages map. |
| `_NewPage()` | Creates a new page map for a fully custom page. |
| `_AddPage()` | Adds a page to the pages map. |
| `_GetWizardPage()` | Returns the page map at a given index. |

**Page Controls**

| Function | Description |
|---|---|
| `_SetPageCtrl()` | Registers a control under a named key on the page. |
| `_GetPageCtrl()` | Returns a control ID registered under a named key. |

**Event Handlers**

| Function | Description |
|---|---|
| `_HandlerArgs()` | Builds an args array for use with `_SetEventHandler()`. |
| `_SetEventHandler()` | Creates an event handler map holding a function reference and arguments. |
| `_SetPageBtnOnClickEvent()` | Registers an OnClick handler for a button on a page. |

**Wizard Buttons**

| Function | Description |
|---|---|
| `_CreateButtons()` | Creates the Cancel/Back/Next button row. |

**Progress Bar**

| Function | Description |
|---|---|
| `_ProgressStep()` | Advances a progress bar and status label by one step. |

**Page Template Events**

| Function | Description |
|---|---|
| `_OnLoad_ReadyPage()` | OnLoad handler that shows a function's returned text in an info label. |
| `_AfterLoad_ProgressPage()` | AfterLoad handler that runs an install/uninstall function and advances the wizard automatically. |
| `_AfterLoad_FinishPage()` | AfterLoad handler that closes the wizard on the next navigation. |
| `_OnClose_FinishPage()` | OnClose handler that opens a file if a checkbox is checked. |
| `_OnClick_SetFolder()` | OnClick handler that opens a folder picker and updates an input. |

**Page Templates**

| Function | Description |
|---|---|
| `_AddIntroPage()` | Adds a welcome/intro page. |
| `_AddPathPage()` | Adds a path selection page with a Browse button. |
| `_AddReadyPage()` | Adds a ready/confirm page. |
| `_AddProgressPage()` | Adds a progress page that runs an install/uninstall function. |
| `_AddFinishPage()` | Adds a finish page, reusing the progress page's controls. |

**Header Construction**

| Function | Description |
|---|---|
| `_CreateSeparator()` | Creates a 1-pixel separator line. |
| `_CreateHeaderTitle()` | Creates the header title label. |
| `_CreateHeaderSub()` | Creates the header subtitle label. |
| `_CreateHeader()` | Creates the full header bar. |

**Wizard**

| Function | Description |
|---|---|
| `_NewWizard()` | Creates the wizard window, header, buttons and an empty pages collection. |
| `_InitWizard()` | Validates the wizard and runs its event loop until it closes. |

## Requirements

- AutoIt 3.3.18.0 or later
- [AutoIt Test Framework](https://github.com/crucialthread/AutoItTestFramework) (`Testable.au3`), referenced through `CrucialWizTstblInclude.au3` - see Installation above for how each option provides it
- SciTE4AutoIt3 (optional, for readable console error messages while a script runs uncompiled)

## License

MIT
