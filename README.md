# lse

*Selenium support for ltest, the LFE testing framework*

<img src="resources/images/se-logo.png" />

## Table of Contents

* [Introduction](#introduction-)
* [Installation](#installation-)
* [Usage](#usage-)
  * [From the REPL](#from-the-repl-)
  * [In a Test Suite](#in-a-test-suite-)
  * [Running a Suite](#running-a-suite-)


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
    {lse, ".*",
      {git, "git@github.com:lfex/lse.git", "master"}}
      ]}.
```

And then do the usual:

```bash
    $ make compile
```


## Usage [&#x219F;](#table-of-contents)

The Selenium macros available in ``include/lse-macros.lfe`` and the
Selenium functions in ``src/lse.lfe`` are generated with
[kla](https://github.com/lfex/kla), and have thus taken advantage of the feature
that converts underscores in the Erlang source library to dashes in the wrapped
LFE library.

If you have your Chrome web browser in a non-standard location, tests against
the webdriver will fail. You will need to symlink your browser to the expected
location or pass options in the capabilities data structure (see the
chromedriver docs for that).


### From the REPL [&#x219F;](#table-of-contents)

```cl
> (lse:start-session
    'se-session
    "http://localhost:9515/"
    (lse:default-chrome)
    10000))
#(ok <0.46.0>)
> (lse:set-url 'se-session "http://google.com")
ok
> (lse:get-page-title 'se-session)
#(ok "Google")
> (set `#(ok ,elem) (lse:find-element 'se-session "name" "q"))
#(ok "0.12670360947959125-1")
> (lse:send-value 'se-session elem "LFE")
ok
> (lse:submit 'se-session elem)
ok
> (lse:get-page-title 'se-session)
#(ok "LFE - Google Search")
```


### In a Test Suite [&#x219F;](#table-of-contents)

Here is some sample usage from a test module (with the ``lselenium``
behaviour):

```lisp
(defmodule lselenium-tests
  (behaviour lselenium)
  (export all))

(include-lib "ltest/include/ltest-macros.lfe")
(include-lib "lse/include/lse-macros.lfe")

(defun get-session ()
  'lselenium-session)

(defun start-session ()
  (lse:start-session
    (get-session)
    "http://localhost:9515/"
    (lse:default-chrome)
    10000))

(defun set-up ()
  (prog1
    (case (start-session)
      (`#(ok ,pid) pid)
      (x x))
    (timer:sleep 3000)))

(defun tear-down (pid)
  (lse:stop-session (get-session)))

(deftestcase google-site-page-title (pid)
  (lse:set-url (get-session) "http://google.com")
  (is-equal #(ok "Google") (lse:get-page-title (get-session))))

(deftestcase google-submit-search (pid)
  (lse:set-url (get-session) "http://google.com")
  (let ((`#(ok ,elem) (lse:find-element (get-session) "name" "q")))
    (lse:send-value (get-session) elem "LFE AND Lisp")
    (lse:submit (get-session) elem)
    (timer:sleep 1500)
    (is-equal #(ok "LFE AND Lisp - Google Search")
              (lse:get-page-title (get-session)))))

(deftestgen foreach-test-suite
  (tuple
    'foreach
    (defsetup set-up)
    (defteardown tear-down)
    (deftestcases
      google-site-page-title
      google-submit-search)))
```

Note that for now, only ``foreach`` fixtures are supported.

### Running a Suite [&#x219F;](#table-of-contents)

To run selenium tests, you will need to:

* start the Chrome driver
* run the selenium tests
* stop the Chrome driver

You'll probably want to add ``make`` targets for these, something
like the following:


```Makefile
$(CHROMEDRIVER):
    mkdir -p bin
    cd bin && \
    curl -O http://chromedriver.storage.googleapis.com/2.9/chromedriver_mac32.zip && \
    unzip chromedriver_mac32.zip

start-chromedriver: $(CHROMEDRIVER)
    -@$(CHROMEDRIVER) --verbose &

stop-chromedriver:
    @ps aux|grep $(CHROMEDRIVER)|grep -v grep|awk '{print $$2}'|xargs kill -15

check-selenium-only:
    @clear
    @PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) \
    erl -cwd "`pwd`" -listener ltest-listener -eval \
    "case 'ltest-runner':selenium() of ok -> halt(0); _ -> halt(127) end" \
    -noshell

check-selenium: clean-eunit compile-tests check-selenium-only

check-all: get-deps clean-eunit compile-no-deps
    PATH=$(SCRIPT_PATH) ERL_LIBS=$(ERL_LIBS) $(LFETOOL) tests all
    make check-selenium-only
```

Using the make targets defined above:

* in one terminal window execute ``make start-chromedriver``
* in another, execute ``make check-selenium``
* when you are done testing, you can execute ``stop-chromedriver``

Output should look something like the following:

```
================================ ltest =================================

---------------------------- Selenium Tests ----------------------------

module: unit-lse-tests
  google_site_page_title_test_case .................................. [ok]
  google_site_page_title_test_case .................................. [ok]
  google_submit_search_test_case .................................... [ok]
  google_submit_search_test_case .................................... [ok]
  time: 19563ms

summary:
  Tests: 4  Passed: 4  Skipped: 0  Failed: 0 Erred: 0
  Total time: 19563ms


========================================================================
```
