# ecltidy
ECL file reformatter and indenter

## Description
ecltidy reads ECL from STDIN and outputs the reformatted text to STDOUT.

## Install
Simply copy ecltidy.pl to any directory in your system PATH.  Typically `$HOME/bin` (or `%USERPROFILE%/bin` on Windows).

## Example usage
Issue the following command to reformat a file:

    ecltidy.pl < eclfile.ecl

## VSCode install 
* Verify that Perl is installed on your system. 

* Verify that ecltidy.pl has been copied to a suitable directory.

* Install the VSCode [Custom Local Formatters](https://marketplace.visualstudio.com/items?itemName=jkillian.custom-local-formatters) extension through the VSCode extensions panel.

* On Windows, edit settings.json to look something like this:

~~~~
    {
      "workbench.colorTheme": "Visual Studio Dark",
      "editor.tabSize": 3,
      "http.proxySupport": "fallback",
      "customLocalFormatters.formatters": [
        {
            "command": "perl %USERPROFILE%\\bin\\ecltidy.pl",
            "languages": [
                "ecl"
            ]
        }
      ],
    }
~~~~

* That's all!  You should now be able to format your ECL code with the command (shift+alt+f)
