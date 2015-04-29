(defmodule lse-runner
  (export all))

(defun selenium (_)
  (ltest-formatter:test-type-header "Selenium Tests")
  (run 'selenium))

(defun selenium ()
  (ltest-formatter:test-suite-header)
  (selenium 'solo)
  (ltest-formatter:test-suite-footer))

(defun run-beams ()
  ;; lfe may not be installed; let's safeguard against a bad user
  ;; experience in that case
  (ltest-runner:run-beams
    'selenium
    (lse:get-selenium-beams (lutil-file:get-cwd))))
