# The Problem

So, you have the file `en.lproj/Localizable.strings` with the following contents:

``` objc
"settings.about.design" = "Design"; // Title in the Settings row for the Designer contact
"settings.about.development" = "Development"; // Title in the Settings row for the Developer contact
```

Then you translate this into `ru.lproj/Localizable.strings` using Crowdin or any other service:

``` objc
"settings.about.design" = "Дизайн"; // Title in the Settings row for the Designer contact
"settings.about.development" = "Разработка"; // Title in the Settings row for the Developer contact
```

Eventually, the file `en.lproj/Localizable.strings` gets larger:

``` objc
"settings.about.design" = "Design"; // Title in the Settings row for the Designer contact
"settings.about.development" = "Development"; // Title in the Settings row for the Developer contact
"settings.about.contact-us" = "Contact Us"; // Title in the Settings row for the Contact sub-screen
"settings.about.help" = "Help"; // Title in the Settings row for the Help sub-screen
```

However, your give translators only changes and get result like this:

``` objc
"settings.about.contact-us" = "Свяжитесь с нами"; // Title in the Settings row for the Contact sub-screen
"settings.about.help" = "Помощь"; // Title in the Settings row for the Help sub-screen
```

Finally, after many iterations, you have a bunch of translations, but still the single `en.lproj/Localizable.strings`, maybe with deleted lines.

# The Solution

`LocalizedStrings.app` is a GUI editor for `.strings` files. You open the document from the hard drive, then Import one or more translated `.strings` files to merge new (translated) values for presented keys. The resulting `.strings` file can be saved back to the hard drive or duplicated into another location. Step-by-step:

1. For example, you have a not-yet-translated or partially-translated file `ru.lproj/Localizable.strings` and localized files `Part1.strings`, `Part2.strings`, `Part3.strings`.
2. Open `ru.lproj/Localizable.strings` with `LocalizedStrings.app` in Finder
3. Import — `Shift-Command-O` — translations `Part1.strings`, `Part2.strings`, `Part3.strings` into the open document.
4. Save the new version with translated values.

*Please note: only the keys presented in the original `.strings` file will be extracted from localized versions.*

# TBD

1. Filter strings by the ‘modified’ flag and export the list as a new `.strings` file ready for translation
2. Improve visual feedback in the table rows after Import, bold font is just a proof-of-concept
3. Provide more information about applied changes i.e. unused strings, maybe in the status bar
4. Recognize more exotic localized string formats with comments in the `.strings` file
