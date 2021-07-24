# SwiftXMLParserDemo

This is a demo for the [SwiftXMLParser](https://github.com/stefanspringer1/SwiftXMLParser).

Build with `swift build -c release`.

Give the path to an XML file as argument to the program and it prints infos about the parts of the XML document the parser finds.

Add the argument "-c" and the elements and all parse events are counted without further output.

Give a second path as second argument to the program and the XML document will be written to this second path.

This demo is published under the Apache License 2.0. For questions or remarks see my contact information on [my website](https://stefanspringer.com).

## Usage on Windows

This section describes how to install Swift on Windows and how to use this Swift package in the Clion IDE. If you do not want to change this package but only would like to build and run it as-is, instead of using Clion you could just run the command `swift build -c release` from within the package to build it.

1. Install Visual Studio (get it from [https://visualstudio.microsoft.com](https://visualstudio.microsoft.com)).
   
2. Install the Swift toolchain (get it from [https://swift.org/download](https://swift.org/download)). Swift will be installed to `C:\Library`. In a newly opened comamnd line winmdows, the command `swift -version` should then print the Swift version.

3. You will have to make the Windows SDK accessable to Swift. Open the `x64 Native Tools for VS2019 Command Prompt` with Administrator rights (via the context menu of the entry for `x64 Native Tools for VS2019 Command Prompt` in the start menu) and inside it, execute the following commands. (Please also see the documentation [https://swift.org/getting-started/](https://swift.org/getting-started/) in case something has changed.)

```batch
copy %SDKROOT%\usr\share\ucrt.modulemap "%UniversalCRTSdkDir%\Include\%UCRTVersion%\ucrt\module.modulemap"
copy %SDKROOT%\usr\share\visualc.modulemap "%VCToolsInstallDir%\include\module.modulemap"
copy %SDKROOT%\usr\share\visualc.apinotes "%VCToolsInstallDir%\include\visualc.apinotes"
copy %SDKROOT%\usr\share\winsdk.modulemap "%UniversalCRTSdkDir%\Include\%UCRTVersion%\um\module.modulemap"
```

4. Different options could be considered for editing Swift source code. We describe the usage of CLion, a commercial IDE. You can get the installer from [https://www.jetbrains.com/clion](https://www.jetbrains.com/clion).

5. Start Clion.

6. Add the Swift plugin via the CLion Settings dialog.

7. Configure the Swift toolchain in CLion (the settings for the Swift plugin might be the last entry in the Settings dialog). Choose the toolchain under `C:\Library\Developer\Toolchains` (select the subdirectory in `Toolchains`).

8. Check-out this Swift package and open in in CLion (open `Package.swift` in CLion and choose "open as project").

9.   Click the Run symbol in CLion. (You can also execute `swift build -c release` for building or `swift run -c release` for also running inside your package. The Swift plugin for CLion is quite new, so this might even be necessary.) With the current state of the project (May 11, 2021) the document should then get validated, validation errors printed, and entity definitions and their usage will be displayed.