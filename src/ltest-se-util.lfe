(defmodule ltest-se-util
  (export all))

(defun get-version ()
  (lutil:get-app-version 'ltest-se))

(defun get-versions ()
  (++ (lutil:get-versions)
      `(#(ltest-se ,(get-version)))))
