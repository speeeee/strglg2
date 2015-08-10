#lang racket/base
(require racket/function
         racket/list)

(define (~ . xs) (foldl compose (last xs) (cdr (reverse xs))))

(struct la (ins cont) #:transparent)
(struct fn (name ins) #:transparent) 
; `fn' is the lowest level. always confirmed simplest form.
; these functions cannot be partially applied at top-level.
(struct exp (h t) #:transparent) ; LISP-style s-expression. (lambda . args-list)
(struct v (val type) #:transparent)

(define (push stk elt) (append stk (list elt)))
(define (pop stk) (car (reverse stk)))
(define (ret-pop stk) (reverse (cdr (reverse stk))))
(define (strcar str) (car (string->list str)))

(define funs (list (fn "+" 2)))

#;(define (string-split-spec str) (map list->string (filter (λ (x) (not (empty? x))) (splt (string->list str) '(())))))
(define (splt str n) (let ([q (if (empty? str) #f (member (car str) (list #\( #\) #\{ #\} #\[ #\] #\:)))])
  (cond [(empty? str) n] ;[(empty? n) (splt (cdr str) (if (char-whitespace? (car str)) n (push n (car str))))]
        [(empty? (pop n)) (splt (cdr str) (if (char-whitespace? (car str)) 
                                              n (if q (append n (list (list (car str)) '())) (push (ret-pop n) (push (pop n) (car str))))))]
        [(char=? (car str) #\") (if (char=? (car (pop n)) #\") 
                                    (splt (cdr str) (append (ret-pop n) (list (push (pop n) #\") '()))) 
                                    (splt (cdr str) (push n (list #\"))))]
        [(char=? (car (pop n)) #\") (splt (cdr str) (push (ret-pop n) (push (pop n) (car str))))]
        [(char-whitespace? (car str)) (splt (cdr str) (push n '()))]
        [q (splt (cdr str) (append n (list (list (car str)) '())))]
        [else (splt (cdr str) (push (ret-pop n) (push (pop n) (car str))))])))

(define (string-split-spec str) (map list->string (foldl (λ (s n) (begin (displayln n)
  (cond [(equal? (car n) 'str) (if (equal? s #\") (push (second n) '()) (list 'str (push (ret-pop (pop n)) (push (pop (pop n)) s))))]
        [(equal? s #\") (list 'str n)] [(member s (list #\( #\) #\{ #\} #\[ #\] #\:)) (append n (list (list s)) (list '()))]
        [(equal? s #\space) (push n '())] [else (push (ret-pop n) (push (pop n) s))]))) '(()) (string->list str))))

(define (check-parens stk) (map rem-plist (cp stk '())))
(define (cp stk n)
  (cond [(empty? stk) n]
        [(equal? (v-type (car stk)) "$close") (let* ([c (case (v-val (car stk)) [("}") "{"] [("]") "["] [(")") "("] [else '()])]
                                                     [l (λ (x) (not (equal? (v-val x) c)))])
           (cp (cdr stk) (push (ret-pop (reverse (dropf (reverse n) l))) (v (reverse (takef (reverse n) l))
                                                                            (case c [("{") "Union"] [("[") "List"] [("(") "PList"] [else '()])))))]
        [else (cp (cdr stk) (push n (car stk)))]))
(define (rem-plist a) (if (equal? (v-type a) "PList") (map rem-plist (v-val a))
                          (if (equal? (v-type a) "List") (v (map rem-plist (v-val a)) "List") a)))