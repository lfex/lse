# ltest-se

## Table of Contents

* [Introduction](#introduction-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [From the REPL](#from-the-repl-)
  * [In a Test Suite](#in-a-test-suite-)


## Introduction [&#x219F;](#table-of-contents)

This library offers a light-weight lispy-wrapper around the
[Erlang Selenium webdriver](https://github.com/Quviq/webdrv). In order to use
ltest's support of Selenium, you will need to have the latest development
releaase of [lfetool](https://github.com/lfe/lfetool/tree/dev-v1#dev-)
installed.


## Installation [&#x219F;](#table-of-contents)

Just add it to your ``rebar.config`` deps:

```erlang
  {deps, [
    ...
    {ltest-se, ".*",
      {git, "git@github.com:lfex/ltest-se.git", "master"}}
      ]}.
```

And then do the usual:

```bash
    $ make compile
```


## Usage [&#x219F;](#table-of-contents)

The Selenium macros available in ``include/ltest-se-macros.lfe`` and the
Selenium functions in ``src/ltest-se.lfe`` are generated with
[kla](https://github.com/lfex/kla), and have thus taken advantage of the feature
that converts underscores in the Erlang source library to dashes in the wrapped
LFE library.

If you have your Chrome web browser in a non-standard location, tests against
the webdriver will fail. You will need to symlink your browser to the expected
location or pass options in the capabilities data structure (see the
chromedriver docs for that).


### From the REPL [&#x219F;](#table-of-contents)

```cl
> (ltest-se:start-session
    'se-session
    "http://localhost:9515/"
    (ltest-se:default-chrome)
    10000))
#(ok <0.46.0>)
> (ltest-se:set-url 'se-session "http://google.com")
ok
> (ltest-se:get-page-title 'se-session)
#(ok "Google")
> (set `#(ok ,elem) (ltest-se:find-element 'se-session "name" "q"))
#(ok "0.12670360947959125-1")
> (ltest-se:send-value 'se-session elem "LFE")
ok
> (ltest-se:submit 'se-session elem)
ok
> (ltest-se:get-page-title 'se-session)
#(ok "LFE - Google Search")
```


### In a Test Suite [&#x219F;](#table-of-contents)

Here is some sample usage from a test module (with the ``ltest-selenium``
behaviour):

```lisp
(defmodule ltest-selenium-tests
  (behaviour ltest-selenium)
  (export all))

(include-lib "include/ltest-macros.lfe")

(defun get-session ()
  'ltest-selenium-session)

(defun start-session ()
  (ltest-se:start-session
    (get-session)
    "http://localhost:9515/"
    (ltest-se:default-chrome)
    10000))

(defun set-up ()
  (prog1
    (case (start-session)
      (`#(ok ,pid) pid)
      (x x))
    (timer:sleep 3000)))

(defun tear-down (pid)
  (ltest-se:stop-session (get-session)))

(deftestcase google-site-page-title (pid)
  (ltest-se:set-url (get-session) "http://google.com")
  (is-equal #(ok "Google") (ltest-se:get-page-title (get-session))))

(deftestcase google-submit-search (pid)
  (ltest-se:set-url (get-session) "http://google.com")
  (let ((`#(ok ,elem) (ltest-se:find-element (get-session) "name" "q")))
    (ltest-se:send-value (get-session) elem "LFE AND Lisp")
    (ltest-se:submit (get-session) elem)
    (timer:sleep 1500)
    (is-equal #(ok "LFE AND Lisp - Google Search")
              (ltest-se:get-page-title (get-session)))))

(deftestgen foreach-test-suite
  (tuple
    'foreach
    (defsetup set-up)
    (defteardown tear-down)
    (deftestcases
      google-site-page-title
      google-submit-search)))
```

To run selenium tests, you will need to add a ``make`` target like the
following, since ``lfetool`` doesn't yet support the ``ltest-selenium``
behaviour:


```Makefile
check-selenium-only: clean-eunit compile-tests
	@clear
	@PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) \
	erl -cwd "`pwd`" -listener ltest-listener -eval \
	"case 'ltest-runner':selenium() of ok -> halt(0); _ -> halt(127) end" \
	-noshell
```

Note that for now, only ``foreach`` fixtures are supported.

