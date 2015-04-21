(defmodule unit-lse-tests
  (behaviour ltest-selenium)
  (export all)
  (import
    (from ltest
      (check-failed-assert 2)
      (check-wrong-assert-exception 2))))

(include-lib "ltest/include/ltest-macros.lfe")
(include-lib "lse/include/lse-macros.lfe")

(defun get-start-pause ()
  3000)

(defun get-search-pause ()
  2000)

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
    (timer:sleep (get-start-pause))))

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
    (timer:sleep (get-search-pause))
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

;; XXX EUnit isn't finding the tests n this suite
(deftestgen setup-test-suite
  (tuple
    'setup
    (defsetup set-up)
    (defteardown tear-down)
    (deftestcases
      google-site-page-title
      google-submit-search)))

;; XXX EUnit isn't finding the tests n this suite
(deftestgen setup-setup-cleanup
  (tuple
    'setup
    (lambda () (set-up))
    (lambda (x) (tear-down x))
    (lambda (x) (google_site_page_title_test_case x))
    (lambda (x) (google_submit_search_test_case x))))
