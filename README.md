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

Copy the final version of the `en.lproj/Localizable.strings` into `ru.lproj/Localizable.strings` and open it with `LocalizedStrings.app`.

Then Import all translations into the document to update all localized keys and see the difference. Save the final `.strings` file with applied changes.

# TBD

1. Export strings which have not yet been translated
2. Improve visual feedback in the table after merge
3. Provide more information about applied changes
4. Add filter to show only changes
