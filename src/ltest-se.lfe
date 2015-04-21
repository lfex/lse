(defmodule ltest-se
  (export all))

(include-lib "ltest-se/include/ltest-se-macros.lfe")

(defun get-selenium-beams ()
  (get-selenium-beams "."))

(defun get-selenium-beams (path)
  (lists:filter
    #'selenium?/1
    (ltest:get-test-beams path)))

(defun selenium? (beam)
  (ltest:has-behaviour? beam 'ltest-selenium))
