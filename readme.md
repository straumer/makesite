# Makesite

This is a static site generator made up of a makefile and shell script(s). It

- Tries to be as POSIX-compliant as possible (suggestions for improvements are welcome).
- Works on most GNU/Linux systems out of the box, using standard tools. 
- Works on BSD systems if GNU `make` and `envsubst` utilities are installed.
- Multilingual.
- Templates based on `envsubst`.
- Plain HTML.
- Simple and hackable, made with advanced users in mind.


## A few things to avoid

- Making directories under `src` with same name as `conf/i18n/*`.


## Basic usage

After cloning the repo, inside root you can run `make`. Nothing will be built.

Now make a file named `src/index.html`:
```
=en
<h1>Example title</h1>
<p>Example bla bla</p>
```

The `=en` part is the language that we're using for the following html. Anything above `=en` would just be ignored. The language is `en` by default as we haven't specified languages yet. Rerun `make` and now `dst/index.html` has been built as the static site. At this point it's just a copy of `src/index.html` (except the `=en` part).

Let's make another file called `src/about.html`:
```
=en
<h1>About</h1>
<p>Another example</p>
```

Run `make` again and we see it made `src/about/index.html`. The path is like that so we can have pretty urls (without .html) without special web server configuration.

Now let's make a common navbar for these pages. We use a template for this. See available templates by running `grep -o "templates/[^ ]*\.html" bin/html | sort | uniq`. We'll use the `templates/site.html` template which is meant to serve as the base template for the whole site. Make the template:
```
<html>
  <head>
    <title>${title}${subtitle}</title>
  </head>
  <body>
    <nav>
        <a href="/">Home</a>
        <a href="/about/">About</a>
    </nav>
    <article>
      ${CONTENT}
    </article>
  </body>
</html>
```

Okay! Now we can navigate between the two pages. The page title looks a bit off though. The `subtitle` env variable above is generated from the first `h1` element found in each file for the `=en` language. We haven't made the overall `title` of the site, so let's make it:
```
mkdir conf
echo 'title="Awesome Site"' > conf/general
make
```

That's a better title. You can add any variables in `conf/general` and use them in templates or src pages.

What if we want to add a new language, say German. For that, make the languages:
```
mkdir conf/i18n
printf 'lang="English"' > conf/i18n/en
printf 'lang="Deutch"' > conf/i18n/de
make
```

We see it made copies of the existing src pages in `dst/de`. Those pages just have the navbar, but we can fill in the German parts for `src/index.html` and `src/about.html` respectively:
```
=en
<h1>Example title</h1>
<p>Example bla bla</p>
=de
<h1>Beispieltitel</h1>
<p>Beispiel bla bla</p>
```

```
=en
<h1>About</h1>
<p>Another example</p>
=de
<h1>Um</h1>
<p>Ein anderes Beispiel</p>
```

To switch between languages more easily, let's also add a language switcher into the navbar. First create the language template:
```
printf '<a href="${ALT_LANG_HREF}">${ALT_LANG}</a>' > templates/alt_lang_item.html
```

Then add to `templates/site.html`:
```
...
    <nav>
      <a href="${LANG_PREFIX}/">Home</a>
      <a href="${LANG_PREFIX}/about/">About</a>
      ${ALT_LANG_ITEMS}
    </nav>`
...
```

That's it! For the rest, read the code.
