;;;; Behaviour module to be used in test modules to mark the module as an ltest
;;;; Selenium module.
;;;;
(defmodule ltest-selenium
  (export all))

(defun behaviour_info
  (('callbacks)
    'undefined)
  ((_)
    'undefined))

(defun get-modules ()
  'ok)
