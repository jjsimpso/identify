#lang racket

(require racket/cmdline)
(require magic/output)

(require (for-syntax syntax/stx syntax/parse racket/syntax racket/string racket/list racket/path))

(define magic-query-list (make-parameter '()))

(define-syntax (require-magic-rename stx)
  (syntax-parse stx
    [(_ path)
     #:with name-prefix (datum->syntax #'path (last (string-split (string-trim (syntax-e #'path) ".rkt") "/")))
     #:with name1 (format-id #'name-prefix "~a-query" (syntax-e #'name-prefix))
     #:with name2 (format-id #'name-prefix "~a-query-all" (syntax-e #'name-prefix))
     #'(begin
         (magic-query-list (cons name1 (magic-query-list)))
         (require (rename-in path (magic-query name1) (magic-query-run-all name2))))]
    [(_) (error "invalid argument")]))

(define-syntax (include-magic-from-dir stx)
  (syntax-parse stx
    [(_ path)
     (let ([magic-files (filter
                         (lambda (p) (path-has-extension? p #".rkt"))
                         (directory-list (syntax-e #'path) #:build? #t))])
       (printf "~a~n" magic-files)
       #`(begin
           #,@(for/list ([file-path magic-files])
                (datum->syntax
                 #'path
                 `(,#'require-magic-rename ,(path->string file-path))))))]
    [(_) (error "invalid argument")]))

;; there are two approaches to building the magic: build each magic file separately or concatenate them all into one file
;; include-magic-from-dir requires each individual file, each of which must be compiled separately. it will be query-magic's
;; responsibility to query each magic individually.
;(include-magic-from-dir "magic")

(define (query-magic path)
  (let loop ([query-list (magic-query-list)])
    (if (null? query-list)
        #f
        (let ([result (with-input-from-file path (car query-list))])
          (if result
              result
              (loop (cdr query-list)))))))


;; or the simpler approach, allmagic.rkt is built by the makefile by concatenating all the magic
(require "allmagic.rkt")
(define (query-monolithic-magic path)
  (with-input-from-file path magic-query))

(define identify-version "0.1.0")
(define run-all (make-parameter #f))

(module+ main
  (set-magic-verbosity! 'error)

  (define target-file
    (command-line
     #:once-any
     [("-v") "Print version number"
             (printf "identify version ~a~n" identify-version)]

     #:once-each
     [("-a") "Run all queries"
             (run-all #t)]
     
     [("-V") "Verbose output"
             (set-magic-verbosity! 'debug)]

     #:args (filename)
     filename))
  
  (when target-file
    (define result (query-monolithic-magic target-file))
    
    (cond
      [(magic-result? result)
       (printf "~a: ~a~n" target-file (magic-result-output-text result))]
      [(list? result)
       (printf "query-all not implemented~n")]
      [else (printf "~a: no match~n" target-file)])))
