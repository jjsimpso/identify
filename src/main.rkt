#lang racket/base

(require racket/cmdline)
(require magic/output)

(require (rename-in "../magic/elf.rkt" (magic-query elf-query) (magic-query-run-all elf-query-all)))
(require (rename-in "../magic/images.rkt" (magic-query image-query) (magic-query-run-all image-query-all)))


(define identify-version "0.1.0")
(define run-all (make-parameter #f))

(set-magic-verbosity! 'warning)


(define (query-magic path)
  (or (with-input-from-file path elf-query)
      (with-input-from-file path image-query)))

(define target-file
  (command-line
   #:once-any
   [("-v") "Print version number"
           (printf "identify version ~a~n" identify-version)]

   #:once-each
   [("-a") "Run all queries"
           (run-all #t)]
   
   #:args (filename)
   filename))

(when target-file
  (define result (query-magic target-file))
  
  (cond
   [(magic-result? result)
    (printf "~a: ~a~n" target-file (magic-result-output-text result))]
   [(list? result)
    (printf "query-all not implemented~n")]
   [else (printf "~a: no match~n" target-file)]))

