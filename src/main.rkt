#lang racket

(require racket/cmdline)
(require magic/output)

(require (for-syntax syntax/stx syntax/parse racket/syntax racket/string racket/list))

(define-syntax (require-magic-rename stx)
  (syntax-parse stx
    [(_ path)
     #:with name-prefix (datum->syntax #'path (last (string-split (string-trim (syntax-e #'path) ".rkt") "/")))
     #:with name1 (format-id #'name-prefix "~a-query" (syntax-e #'name-prefix))
     #:with name2 (format-id #'name-prefix "~a-query-all" (syntax-e #'name-prefix))
     #'(require (rename-in path (magic-query name1) (magic-query-run-all name2)))]
    [(_) (error "invalid argument")]))

;; broken due to hygiene issues. the required bindings aren't created in the correct scope.
;; my attempts to fix using datum->syntax to set the scope push require out of the module level,
;; which is also an error.
(define-syntax (include-magic-from-dir stx)
  (syntax-parse stx
    [(_ path)
     (let ([magic-files (filter
                         file-exists?
                         (directory-list (syntax-e #'path) #:build? #t))])
       (printf "~a~n" magic-files)
       #`(begin
           #,@(for/list ([file-path magic-files])
                #`(require-magic-rename #,(path->string file-path)))))]
    [(_) (error "invalid argument")]))

;(include-magic-from-dir "../magic")

;(require (rename-in "../magic/elf.rkt" (magic-query elf-query) (magic-query-run-all elf-query-all)))
;(require (rename-in "../magic/images.rkt" (magic-query image-query) (magic-query-run-all image-query-all)))
(require-magic-rename "../magic/elf.rkt")
(require-magic-rename "../magic/images.rkt")

(define identify-version "0.1.0")
(define run-all (make-parameter #f))

(define (query-magic path)
  (or (with-input-from-file path elf-query)
      (with-input-from-file path images-query)))

(module+ main
  (set-magic-verbosity! 'warning)

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
      [else (printf "~a: no match~n" target-file)])))
